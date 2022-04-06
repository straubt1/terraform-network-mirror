# terraform-network-mirror

Simple example on how to create a [Terraform Network Mirror](https://www.terraform.io/docs/internals/provider-network-mirror-protocol.html).

## How to use this Repo

1. Run the `create-mirror.sh` script.
2. (optional) Run the `create-core.sh` script.
3. Run the Terraform for the S3 Bucket and objects.

### Run the `create-mirror.sh` script

This script basically abuses the `terraform providers mirror` command to automagically create the mirror locally for each of our desired version constraints.

To run this script create a `.json` file such as the one in `examples/test.json`.

The format looks like this:
```json
{
    "providers": [{
            "namespace": "hashicorp",
            "name": "aws",
            "versions": [
                "3.11.0",
                "3.12.0"
            ]
        }
    ]
}
```

Populate this with the providers you wish to have available in your network mirror.

Run the command, it will look something like this:

```sh
./create-mirror.sh examples/test.json
```

> Note: Not all providers are in the hashicorp namespace.

### Run the `create-core.sh` script

This script will download core versions of terraform in their zip format, which can be registered in TFE to pull internally, instead of the public internet.

To run this script create a `.json` file such as the one in `examples/test.json`.

The format looks like this:
```json
{
    "core": [
        "0.14.7",
        "0.13.6",
        "0.11.14"
    ]
}
```

Populate this with the versions you wish to have available.

Run the command, it will look something like this:

```sh
./create-core.sh examples/test.json
```

sync provider versions with hashicorp:
```sh
./sync_version_with_hashicorp.sh hashicorp random
./create-mirror.sh ./hashicorp-random.json
```

> Note: This configuration can live in the same file as the providers above.

### Run the Terraform for one of the clouds

`cd` into either of the ["aws", "azure", "gcp"] folders to create a bucket and populate it with all the files generated in the previous step.

Open up `main.tf` and update the locals block to acceptable values, ensuring your bucketname has a unique name.

For simplicity, export environment variables for the provider credentials.

Apply the terraform by first running `terraform init` and then `terraform apply`.

You should end up with something like this at the end:

```hcl
Apply complete! Resources: xx added, 0 changed, 0 destroyed.

Outputs:

terraform-mirror-url = https://tstraub-test-network-provider.s3.amazonaws.com/
```

Now you can use that url in your [Terraform CLI Configuration](https://www.terraform.io/docs/commands/cli-config.html#provider-installation):

```hcl
provider_installation {
  network_mirror {
    url = "https://tstraub-test-network-provider.s3.amazonaws.com/"
  }
}
```
