variable "resource_group_location" {
  type        = string
  default     = "centralus"
  description = "Location of the resource group."
}

variable "resource_group_name" {
  type        = string
  description = "Name of the resource group."
  sensitive   = true
}

variable "newrelic_account_id" {
  type        = string
  description = "The New Relic Account ID."
  sensitive   = true
}

variable "newrelic_region" {
  type        = string
  description = "The New Relic cloud region."
  default     = "US"
}

variable "newrelic_application_name" {
  type        = string
  description = "The New Relic application name."
  sensitive   = true
}

