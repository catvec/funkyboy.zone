# ProtonMail Bridge
Runs the ProtonMail Bridge in an externally accessible way.

# Table Of Contents
- [Overview](#overview)

# Overview
Migrating out of ProtonMail to another email provider can be a tricky process. ProtonMail easily provides `.eml` files. However to import those files into another provider you often need third party tools. Often requiring enterprise like applications and potentially per user licensing.

Email providers, like Google Workspaces, often provide migration services included in their offerings. Often these tools work by connecting to your old email server (using a protocol like IMAP) and then pulling in all your old emails. This ends up being problematic if you are migrating from ProtonMail. As ProtonMail does not provide public servers which implement IMAP. Instead all communications regarding your email inbox content is done via custom ProtonMail protocols. 

There is a way around this. ProtonMail recognizes that many would like to use their own email clients (ex., Thunderbird or Mutt) which speak IMAP. To accomodate this use case ProtonMail provides a [bridge application](https://proton.me/mail/bridge). This application connects to ProtonMail via their custom protocol and then hosts a locally available IMAP (and SMTP) email server.

There is one problem with the ProtonMail Bridge application. It only accepts traffic on localhost. So you can't host it temporarily and have Google Workspaces pull from it. There is of course a way around this. See [Instructions](#instructions) for more details.

# Instructions
To run ProtonMail Bridge so that it can be externally accessible for IMAP migration services:

1. Clone down the [ProtonMail Bridge source code](https://github.com/ProtonMail/proton-bridge)
2. Modify the code to allow listening on `0.0.0.0` instead of `127.0.0.1`
  - As of commit `f84067de3e596c9d103210d3ee34c1504becfc02` the [`host.diff` patch](./patches/host.diff) will achieve this
    
	However, the source code of the application might change. Leading this patch to no longer be valid. The way I found the code to patch was by searching for `127.0.0.1` in the source code, and replacing that will `0.0.0.0`. 
3. Build the patched ProtonMail Bridge into a Docker image so you can deploy it:
   - Apply the [`patches/docker.diff` patch](./patches/docker.diff)
     - This patch is valid as of commit `f84067de3e596c9d103210d3ee34c1504becfc02`, but it should be less volatile. This patch should only need to be changed if the way ProtonMail Bridge is built changes
	 - The files created by this patch in the `docker-conf/` directory are slightly modified from [shenxn's protonmail-bridge-docker project](https://github.com/shenxn/protonmail-bridge-docker), distributed under the [GPL v3.0 license](https://github.com/shenxn/protonmail-bridge-docker/blob/ca1fd017f0e6ac5ee2526fcb4f65e57f7b2f00b8/LICENSE)
	- Build and push the Docker image:
	  ```
	  docker build -t TAG .
	  docker push TAG
	  ```
4. Modify the [`bases/server/resources/deployment.yaml`](./bases/server/resources/deployment.yaml) file to use the Docker image you pushed (Right now it uses `noahhuppert/proton-bridge:all-host-5` built on commit `f84067de3e596c9d103210d3ee34c1504becfc02`, but I am not maintaining that image as it was only for my personal use, and it might be deleted at some point)
5. Modify the [`bases/server/resources/ingress.yaml`](./bases/server/resources/ingress.yaml) file with your own domain name. This must be a domain which you control and can get SSL certificates for (See [cert-manager](../cert-manager) for a way of using Lets Encrypt with Kubernetes, the rest of these instructions will assume this is what you're using)
6. Deploy the Kubernetes manifests:
   ```
   kubectl apply -k bases/server/
   ```
   - Wait for the load balancer for the service to be provisioned, you will know its done when the `kubectl -n protonmail-bridge get svc` command shows an external IP for the `protonmail-bridge` service
   - Wait for cert-manager to obtain a certificate for your domain name, you will know its done when the `kubectl -n protonmail-bridge get secrets` command shows a secret named `protonmail-bridge-ingress-cert` exists
7. Create a DNS entry in your DNS provider which points the domain name you choose to the external IP of the service
8. Obtain your SSL key and certificate
   - The key and certificate are stored in a Kubernete secret created by cert-manager, to export them into files on your local machine run:
     ```
	 kubectl -n protonmail-bridge get secrets protonmail-bridge-ingress-cert -o json | jq -r '.data["tls.key"]' | base64 -d | tee tls.key
	 kubectl -n protonmail-bridge get secrets protonmail-bridge-ingress-cert -o json | jq -r '.data["tls.key"]' | base64 -d | tee tls.crt
	 ```
	 This will place the `tls.key` and `tls.crt` files in your working directory
   - Copy the `tls.key` and `tls.cert` file into the pod running your container:
     ```
	 kubectl -n protonmail-bridge cp ./tls.key POD:/root
	 kubectl -n protonmail-bridge cp ./tls.crt POD:/root
	 ```
	 Be sure to replace `POD` with the name of the pod created for the deployment (Find this by running `kubectl -n protonmail-bridge get pods`)
9. Setup ProtonMail bridge:
   - First exec into the Kubernetes deployment running your container, deployment just provides a dev toolbox with the patched bridge ready to go, you will still have to run commands to start it. To exec into the deployment run:
     ```
	 kubectl -n protonmail-bridge exec -it deployment/protonmail-bridge -- /protonmail/entrypoint.sh
	 ```
	 This will start a REPL like interface for the ProtonMail Brisge, run all the following sub-steps within this step in this new shell.
   - Login to your ProtonMail account by running `login`, once you have entered your credentails the bridge program will automatically start a synchronization process (It will print its progress via log statements). Wait for this synchronization process to complete before moving on to the next step (It might take a few hours)
   - Run `info` to see details about the local email servers its running, in the "IMAP Settings" check the following:
     - Ensure `Address` says `0.0.0.0`, if it doesn't this means the patch to allow listening on all address is not working, probably because ProtonMail have changed the bridge source code and a patch is required. If this is the case then go back to the first step and keep trying to make a new patch until you pass this step
	 - Ensure `Security` says `SSL`, if it doesn't then run `change imap-security`. It should ask you if you want to change from `STARTTLS` to `SSL`, say `yes`. Then re-run `info` and ensure `SSL` is the new value
	 - Take note of the `Username` and `Password` values as you will need to give those to anything that wants to connect to the ProtonMail Bridge IMAP server
   - Leave this terminal open for the rest of the instruction, if you close it it will stop the ProtonMail Bridge program, and your new email provider will not be able to read your old emails
 10. The ProtonMail Bridge program should now be running an IMAP server with SSL under your domain name
    - To test this run:
	  ```
	  openssl s_client -connect <DOMAIN NAME>:993
	  ```
	  Be sure to replace `<DOMAIN NAME>` with the domain name you choose.  
	  
	  If all is working well the SSL certificate should be printed, followed by the ProtonMail Bridge's IMAP server advertising its capabilities, this should look something like:
	  ```
	  OK [CAPABILITY ID IDLE IMAP4rev1 MOVE STARTTLS UIDPLUS UNSELECT] Proton Mail Bridge 03.08.01 - gluon session ID 3
	  ```
11. Now you can begin email migration using your new email providers IMAP migration tool, simply point it at your domain name. The username and password for this IMAP server are the values which were printed out under the `Username` and `Password` fields of the `info` command from above
   - For example to use Google Workspaces build in IMAP migration tool
     - Go to the admin dashboard and navigate to Account > Data migration and enter the following settings:
       - Migration source:  "Other IMAP server" 
	   - Connection protocol: "IMAP" and then enter the domain you choose above (Without any scheme or ports)
	   - Role account: Enter the username and password from the `info` command above
	 - Now start the migration tool and continue following Google's guides
12. Cleanup: ProtonMail Bridge's development team has legitimate concerns regarding allowing external network traffic to access the bridge program. This isn't something you want to keep running after the migration is done.  

    The `protonmail-bridge` namespace in Kubernetes contains a persistent volume claim with all your emails from ProtonMail on it. The safest way to cleanup after this process is just to delete the `protonmail-bridge` namespace. This will delete all resources from the steps above.
