variable "vms" {
	type = string
	default = 2
}

variable "ami" {
	type = string
	default = "ami-0eb9c3d4a1f2f6bf8"
}

variable "azs" {
	type = list
	default = ["us-west-1b","us-west-1c"]
}

variable "subnet_cidr" {
	type = list
	default = ["10.0.101.0/24","10.0.102.0/24"]
}

variable "cidr_block" {
	type = list
	default = ["0.0.0.0/0"]
}

variable "v_size" {
	type = string
	default = 5
}

variable "v_device_name" {
	type = string
	default = "/dev/sdh"
}

variable "v_type" {
	type = string
	default = "gp2"
}

variable "v_iops" {
	type = string
	default = 150
}

variable "public_key" {
	type = string
	default = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCnX0ZL2wo0qfSM1/078G1FXDljMsC/Suz5vOfs3qkM6WYtKhs5fEs7rcUk9dlPaVmpDrfVbCd++fPghP51RUTSB24y/eTCMa9FMM3PE+zpcWBRW9anMo7FQZ1sOPGtAu20uKNZgFV/yASEnRDLa2OEh8ahHwOlxAAO/YHi+9c+aKuNtz9V8POoAJ75qQTjprnLwGFpWFRhsWuRX0vqL5ztmBq0HgVa+kbfQobMjVe0PUJh+RIE8wOehfDPzfzoVXe4gqjXWC5b7NO0Hla5wtxi0bgpsTr7LtYTLQxr0/d6yTGnya0vp7zl+02NsfJqd5s4SO7/1jIWdXxmGwCKK/iU+ws5/JXfVDV05S78xo+Br9aMaTJXWN+f0U5m73C52XcLiBxVBjHubUjiPG/i/+nnIH+ASgJZB6lWbLa2Fyq6VI2/ZYP9qn5LDraqW0UGugmNs8SvqdxvZA/QYgSlGd7smv04X9XiF1hYHXiwGRkRwwy/fNDzH6KB9zsIjPmC7Wc= samuel@control-plane.minikube.internal"
}
