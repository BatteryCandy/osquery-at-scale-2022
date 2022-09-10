# Basic Golden Image  
This example is part of my osquery@scale 2022 talk on running short lives instances that are constantly rebuilt to disrupt attacker dwell time and encourage making mistakes to improve the odds of detection. This excerpt is the basics necessary to get a golden image pipeline in place.  This will install osquery for security visibility as well as log forwarding via `fluent-bit` pre-configured to send logs via HTTP to an endpoint you have already configured. This is a very basic setup and the image should be properly hardened prior to using in a production pipeline. To make this fully featured, along with hardening, you would likely want to add a github/circleci/jenkins/etc.. action to run on a cron schedule which completes the automation process. 

## In order to make useful  
Update `base-image.pkr.hcl` adding your AWS Org ARN or remove this piece completely
```
ami_org_arns = [
      "arn:aws:organizations::<root_acct_id>:organization/<org_id>"
    ]
```  
Update `root/etc/fluent-bit/fluent-bit.conf` with your host to collect logs & your log domain secret header value
```
[OUTPUT]
    Name        http
    Host        <host>
    ...
    Header      X-Secret-Header Hunter2

```

## Integration with HCP Packer  
- Go to access control and create a `packer` service principal   
- Export the secret key and id  
    ```
    export HCP_CLIENT_ID=
    export HCP_CLIENT_SECRET=
    ```  
- `packer init . && packer fmt . && packer validate .`
- If everythings good `packer build .`
