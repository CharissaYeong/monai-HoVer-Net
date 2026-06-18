variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "ap-southeast-1"
}

variable "name_prefix" {
  description = "Resource name prefix"
  type        = string
  default     = "charissa"
}

variable "project" {
  description = "Project name"
  type        = string
  default     = "monai-app"
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "dev"
}

variable "glacier_transition_days" {
  description = "Number of days before moving raw images to Glacier"
  type        = number
  default     = 30
}