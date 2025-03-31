from diagrams import Diagram, Cluster
from diagrams.aws.compute import EC2
from diagrams.aws.network import ELB, IGW, NATGateway ,CloudFront

# Create a diagram
with Diagram("Architecture", outformat="pdf"):

    ec2_js = EC2("Jumpstation")

    # Create a Load Balancer
    lb = ELB("Load Balancer")

    igw = IGW ("Internet Gateway")
    ngw = NATGateway ("NAT Gateway")
    internet = CloudFront ("Internet")
    internet1 = CloudFront ("Internet")
    internet2 = CloudFront ("Internet")



    with Cluster(""):
        svc_group = [EC2("Active Instance"),
                     EC2("Passive Instance")]

                 


    svc_group >> ngw >> igw >> internet
    internet1 >> ec2_js >> svc_group
    svc_group << lb << internet2




