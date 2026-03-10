# Complete NLB Example

This example demonstrates how to use the Network Load Balancer (NLB) module to create a complete NLB setup with the following components:

- Network Load Balancer with Internet access
- Server Group with health check configuration
- TCP Listener on port 80
- VPC and VSwitches for the infrastructure
- Security Group with HTTP/HTTPS access rules

## Usage

To run this example, you need to execute:

```bash
$ terraform init
$ terraform plan
$ terraform apply
```

Note that this example may create resources which cost money. Run `terraform destroy` when you don't need these resources.

## Architecture

This example creates:

1. **VPC Infrastructure**: A VPC with two VSwitches in different availability zones
2. **Security Group**: With rules allowing HTTP (80) and HTTPS (443) traffic
3. **Network Load Balancer**: Internet-facing NLB with cross-zone load balancing enabled
4. **Server Group**: With TCP protocol and weighted round-robin scheduling
5. **Listener**: TCP listener on port 80 for HTTP traffic

## Configuration Details

- **Load Balancer Type**: Network Load Balancer
- **Address Type**: Internet (public access)
- **IP Version**: IPv4
- **Cross-Zone**: Enabled for high availability
- **Server Group Protocol**: TCP
- **Scheduling Algorithm**: Weighted Round Robin (Wrr)
- **Health Check**: TCP health check with default settings

## Next Steps

After deploying this example:

1. Add backend servers to the server group using the `server_attachments_config` variable
2. Configure additional listeners for HTTPS traffic if needed
3. Set up SSL certificates for TCPSSL listeners
4. Configure custom security policies if required

## Clean Up

To destroy the resources created by this example:

```bash
$ terraform destroy
```