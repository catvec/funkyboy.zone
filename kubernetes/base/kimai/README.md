# Table Of Contents
- [Overview](#overview)
- [Instructions](#instructions)
- [Operations](#operations)

# Overview
Runs the [Kimai](https://www.kimai.org) time tracker and invoice web service.

# Instructions
1. Create a copy of [`base/conf/mysql-example.env`](./base/conf/mysql-example.env) named `mysql.env` and fill in your values
2. Create a copy of [`base/conf/kimai-example.env`](./base/conf/kimai-example.env) named `kimai.env` and fill in the password from `mysql.env`

# Operations
## Create A User
Exec into the Kimai container to create a user:

```
kubectl -n kimai exec -it deployment/kimai -- /opt/kimai/bin/console kimai:user:create <USERNAME> <EMAIL> ROLE_SUPER_ADMIN
```

This will ask you for a password.