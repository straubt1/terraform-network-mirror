# terraform-network-mirror

Simple example on how to create a [Terraform Network Mirror](https://www.terraform.io/docs/internals/provider-network-mirror-protocol.html).

## How to use this Repo

1. Run the `create-mirror.sh` script.
2. Run the Terraform for the S3 Bucket and objects.

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

### Run the Terraform for the S3 Bucket and objects

Create the S3 bucket and populate it with all the files generated in the previous step.

Open up `main.tf` and update the locals block to acceptable values, ensuring your S3 bucket has a unique name.

Apply the terraform with a `terraform apply`.

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
