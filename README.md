# **FORTE**: **F**ive-G **O**ptimized by **R**eal **T**ime **E**dge

This project describes deployment, operation and troubleshooting of the open-source [Free5GC](https://www.free5gc.org/) package on [Equinix Network Edge](https://www.equinix.com/products/digital-infrastructure-services/network-edge).

## Overview of 5G Stand Alone (SA) Architecture


The 5th Generation of Mobile Networks (a.k.a. 5G) represents a dramatic technological inflection point where the cellular wireless network becomes capable of delivering significant improvements in capacity and performance, compared to the previous generations and specifically the most recent one – 4G LTE.

In 5G, two key parts of the wireless/mobile network receive major upgrades:

* 5G New Radio (5GNR) defines a new air interface structure, new antennae design (massive Multiple Input Multiple Output arrays – mMIMO) and radio transmission methods (beamforming/beam steering).  This enables significant increases in data rates, decreases in the “air interface” latency, as well as the improvements in the capacity (number of connected devices).
* 5G Core (5GC) defines core control (signaling) and user plane (data) capabilities that make use of cloud native virtualization and enable features such as Control and User Plane Separation (CUPS) and Network Slicing.   This allows for the development of unique services not previously available or difficult to implement in 4G.

5G will provide significantly higher throughput than existing 4G networks. Currently 4G LTE is limited to around 150 Mbps. LTE Advanced increases the data rate to 300 Mbps and LTE Advanced Pro to 600Mbps-1 Gbps. The 5G downlink speeds can be up to 20 Gbps. 5G can use multiple spectrum options, including low band (sub 1 GHz, mid-band 1-6 GHz and mmWave 28, 39 GHz). The mmWave spectrum has the largest available contiguous bandwidth capacity (~1000 MHz) and promises dramatic increases in user data rates. 5G enables advanced air interface formats and transmission scheduling procedures that decrease access latency in the Radio Access Network by a factor of 10 compared to 4G LTE.

![](images/5G-bw-1.png)

	    5G fundamental requirements and use cases

5G Service Based Architecture (SBA) is shown below. 
![](images/5G-SBA.png) 

		5G Service Based Architecture

The full description of 5G SBA is outside of the scope of this paper. Please refer to 3GPP TS 23.501 for the technical specification of SBA. Below we highlight some SBA functions and interfaces that are relevant to the discussion in this document.

* UE – User Equipment. These are mobile devices equipped with 5G NR capabilities and used for consumer, business, IoT and vehicular applications.
* RAN – Radio Access Network. RAN may further be broken down into the Radio Units (RU), Distributed Units (DU) and Centralized Units (CU). The combination of DU and CU is also referred to as gNB. The UE handovers between gNBs are handled using the Xn interface.
* UPF – User Plane Function. UPF handles Uplink and Downlink data forwarding between the RAN and the Data Networks (DN). The N3 interface is used between gNB and UPF. The N6 interface is used between the UPF and DNs.
* AMF – Access and Mobility Function. AMF is a Control Plane function responsible for UE registration, session and mobility management.
* SMF – Session Management Function. SMF is responsible for bearer and session management including the management of UE IPv4 and IPv6 addressing.
* PCF – Policy Control Function. PCF is responsible for managing and authorizing session parameters for the UE including data rate, QoS and charging.
* NSSF – Network Slice Selection Function. NSSF is responsible for establishing and managing Network Slicing parameters for the UE sessions including the 5GC and Transport domains. NSSF is described in 3GPP TR 28.801.

## FORTE Design

Forte is a deployment of the open-source 5G package - [Free5GC](https://www.free5gc.org/) on [Equinix Network Edge](https://www.equinix.com/products/digital-infrastructure-services/network-edge) platform. The deployment consists of 3 VMs linked to a virtual router. Each VM runs a Kubernetes stack in it (Ubuntu, Docker, K8s, Flannel, Multus, Helm) and the 5G function pods. 

There is a 5G Control Plane cluster (f5gc-cp), 5G User Plane cluster (f5gc-upf) and the simulated UE (device) and GNB (tower) cluster (f5gc-ueran). All are linked to the virtual router (Cisco 8000v) that allows to connect VMs together and to the Internet and Public/Private Clouds via [Equinix Fabric](https://www.equinix.com/products/digital-infrastructure-services/equinix-fabric).

The Forte project is targeted for developers/architects to try out the optimal placement of 5G functions on the edge infra that can be deployed and provisioned in (near) real time. We call it FORTE - Five-G Optimized by Real Time Edge. The detailed design diagram is shown below.

![](images/FORTE-Design.png)

### Virtual Machines


