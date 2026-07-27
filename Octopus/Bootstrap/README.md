# Octopus Deploy local bootstrap

Terraform to seed a **local** Octopus Deploy instance for development work.

## What it creates

In each of three spaces — `Default` (built-in), `space-2`, and `space-3`:

- **3 environments**: `dev`, `staging`, `prod`
- **1 Docker package feed** pointed at Docker Hub (`https://index.docker.io`)
- **1 Git credential** (username/password)

`space-2` and `space-3` are created by this config; the built-in `Default`
space is reused.

## Layout

```
Bootstrap/
├── versions.tf          # Terraform + provider requirements
├── providers.tf         # One provider per space (default + 2 aliases)
├── variables.tf         # Root inputs (all secrets are sensitive)
├── spaces.tf            # Creates space-2 and space-3
├── main.tf              # Calls the module once per space
├── outputs.tf           # Ids of everything created
└── modules/space-bootstrap/   # Environments + Docker feed + Git credential
```

The `space-bootstrap` module is space-agnostic: each `module` block in
`main.tf` passes in a provider already scoped to the target space, so the same
resources are created in every space.

## Usage

```sh
cd Octopus/Bootstrap
cp terraform.tfvars.example terraform.tfvars   # then edit with real values
terraform init
terraform plan
terraform apply
```

## Secrets

No credentials live in the `.tf` files. All secrets are declared as `sensitive`
variables and supplied through `terraform.tfvars`, which is gitignored. Only
`terraform.tfvars.example` (placeholders) is committed.

| Variable | Purpose |
|---|---|
| `octopus_address` | Base URL of your local instance (default `http://localhost:8080`) |
| `octopus_api_key` | Octopus API key (`API-...`) |
| `dockerhub_username` / `dockerhub_password` | Docker Hub feed auth (blank = anonymous) |
| `git_username` / `git_password` | Git credential |

## Notes

- The aliased providers reference the new spaces' ids, so `terraform apply`
  creates the spaces and their contents in a single run. Because of that
  dependency, always let Terraform manage the full lifecycle — don't delete a
  space out-of-band while it's still in state.
- Provider used: [`OctopusDeployLabs/octopusdeploy`](https://registry.terraform.io/providers/OctopusDeployLabs/octopusdeploy/latest/docs).
