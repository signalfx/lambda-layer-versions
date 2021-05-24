# Demo the Splunk Extension for AWS Lambda

## Prerequisites

* [AWS CLI](https://aws.amazon.com/cli/) v2

**_Note:_** Scripts in this demo don't override settings of AWS CLI, so before running them,
make sure your default profile is the appropriate one, or override it in your shell using the following script:

```shell
export AWS_PROFILE=<profile name>
export AWS_DEFAULT_REGION=<region>
```

## Deployment

First, you'll run scripts that create two functions:
* one that uses buffering and sends data points every 30 seconds
* another that doesn't buffer data points and sends them immediately after the function is called

Make sure you're in the right directory. From the root of the repo, run: 

```shell
cd docs/examples
```

Prepare:
* a realm where your organization resides (you can find it in [your profile](https://docs.signalfx.com/en/latest/admin-guide/tokens.html#access-tokens))
* [an access token](https://docs.signalfx.com/en/latest/admin-guide/tokens.html#access-tokens) of your organization
* arn of extension (you can find them in [the versions file](https://github.com/signalfx/lambda-layer-versions/blob/master/lambda-extension/lambda-extension-versions.md)) - make sure this is for the region where you intend to create the functions

```shell
SPLUNK_REALM=<realm> SPLUNK_ACCESS_TOKEN=<token> EXTENSION_ARN=<arn> scripts/init.sh
```

**_Note:_** Sometimes propagation of changes in IAM across regions takes longer than expected,
and slow propagation of changes may cause the script to fail to create a function. If you see such an error, run the script
again.

## Test

Now you can run both functions, for example:

```shell
scripts/invoke-buffered.sh 100 & scripts/invoke-real-time.sh 100 & wait
```

You can control how many times the function will be called in the above script by specifying a number as the script parameter.

Visit [our built-in dashboard](../README.md#Built-in-dashboard) to see if data points are coming.

## Cleanup

To remove the functions created before, run the following:

```shell
scripts/cleanup.sh
```
