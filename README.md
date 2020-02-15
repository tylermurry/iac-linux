# iac-linux
Houses the code and azure pipeline to create a basic linux vm

# Notes along the way
* Probably should allow this component to create multiple vms at a time and expose a count variable
* The creation of the vnet/subnet is typically something that has already been done in most enterprises. This component should evolve to accept a except a vnet/subnet.
* A storage account needs to be provided so that terraform has a place for the statefile  
* Every iac pipeline should publish a `result.json` file to the build artifacts. This file contains organized output of the job (e.g. the ip address for the linux vm)
* Probably want to get the secret values from a key vault
