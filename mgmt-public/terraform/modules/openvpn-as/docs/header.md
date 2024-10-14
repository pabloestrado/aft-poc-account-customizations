# OpenVPN Access Server on EC2 Instance

## General

This module launches an OpenVPN Access Server from official OpenVPN Inc's AWS Marketplace AMI.
OpenVPN AS is automatically configured to allow admin access with randomly generated password.

Copyright (c) 2023 Automat-IT


### OpenVPN AS Licensing

As there are different kind of AMIs for OpenVPN AS available, with different licensing options,
the module uses a data source to find the correct AMI in the region. However AWS Marketplace
subscription is required prior to applying the module.

Selection is performed by product code:

+---------------------+-------------------------------+--------------------------------------------------+
|       Option        |        Product Code           |                  Marketplace page                |
+=====================+===============================+==================================================+
| BYOL/Free (2 users) | ``f2ew2wrz425a1jagnifd02u5t`` | https://aws.amazon.com/marketplace/pp/B00MI40CAE |
+---------------------+-------------------------------+--------------------------------------------------+
| 5 users ($0.07/hr)  | ``3ihdqli79gl9v2jnlzs6nq60h`` | https://aws.amazon.com/marketplace/pp/B072YZPM2M |
+---------------------+-------------------------------+--------------------------------------------------+
| 10 users ($0.10/hr) | ``8icvdraalzbfrdevgamoddblf`` | https://aws.amazon.com/marketplace/pp/B01DE77JZY |
+---------------------+-------------------------------+--------------------------------------------------+

### Placement

It is recommended to choose a random public subnet and place the OpenVPN instance there. This
approach allows to spread the load over different availability zones and reduces the chances of
over-capacity errors from Amazon.

This choice should be made outside of this module - for example, it is usually better to place all
the internal resources like Jenkins/Nexus/VPN servers in the same AZ to reduce latency and
cross-zone traffic, so the selected subnet can be used for other resources as well.