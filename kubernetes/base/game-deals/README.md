# Game Deals
- [Setup](#setup)

# Setup
Make a copy of the following `.env` configuration files and fill in your own values (Remove `.example` from the name when making a copy):

- `conf/postgres.example.env`
- `conf/app-config.example.env`
- `conf/app-secret.example.env`
  - Use following Terraform (`terraform/compute/`) outputs for the env vars:
    | Env Var         | Terraform Output               |
    |-----------------|--------------------------------|
    | `S3_ACCESS_KEY` | `game_deals_spaces_access_key` |
    | `S3_SECRET_KEY` | `game_deals_spaces_secret_key` |

    Retrieve these by running the following in the repo root:
    
    ```bash
    ./client-scripts/setup-cloud.sh -o terraform/compute/ output 
    ```

# Todo
- Setup DO space
- Setup PG backups
