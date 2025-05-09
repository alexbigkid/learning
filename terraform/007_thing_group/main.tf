locals {
  common_tags = {
    env = "dev"
  }
  deployment_region = "us-west-2"
}

provider "aws" {
  region = local.deployment_region
}

# Parent agent auto update groups
# ----------------------------------------------------------------
resource "aws_iot_thing_group" "AgentAutoUpdatePatch" {
  name = "AgentAutoUpdatePatch"
}

resource "aws_iot_thing_group" "AgentAutoUpdateMinor" {
  name = "AgentAutoUpdateMinor"
}

resource "aws_iot_thing_group" "AgentAutoUpdateMajor" {
  name = "AgentAutoUpdateMajor"
}


# Patch versions - agent auto update groups
# ----------------------------------------------------------------
resource "aws_iot_thing_group" "AgentAutoUpdatePatchASAP" {
  name = "AgentAutoUpdatePatchASAP"

  parent_group_name = aws_iot_thing_group.AgentAutoUpdatePatch.name

  properties {
    attribute_payload {
      attributes = {
        autoUpdate = "patch"
        updateType = "asap"
      }
    }
    description = "Agent auto-update immediately, only patch versions"
  }

  tags = local.common_tags
}

resource "aws_iot_thing_group" "AgentAutoUpdatePatchDaily" {
  name = "AgentAutoUpdatePatchDaily"

  parent_group_name = aws_iot_thing_group.AgentAutoUpdatePatch.name

  properties {
    attribute_payload {
      attributes = {
        autoUpdate = "patch"
        updateType = "daily"
      }
    }
    description = "Agent auto-update daily, only patch versions"
  }

  tags = local.common_tags
}

resource "aws_iot_thing_group" "AgentAutoUpdatePatchWeekly" {
  name = "AgentAutoUpdatePatchWeekly"

  parent_group_name = aws_iot_thing_group.AgentAutoUpdatePatch.name

  properties {
    attribute_payload {
      attributes = {
        autoUpdate = "patch"
        updateType = "weekly"
      }
    }
    description = "Agent auto-update weekly, only patch versions"
  }

  tags = local.common_tags
}


# Minor versions - agent auto update groups
# ----------------------------------------------------------------
resource "aws_iot_thing_group" "AgentAutoUpdateMinorASAP" {
  name = "AgentAutoUpdateMinorASAP"

  parent_group_name = aws_iot_thing_group.AgentAutoUpdateMinor.name

  properties {
    attribute_payload {
      attributes = {
        autoUpdate = "minor"
        updateType = "asap"
      }
    }
    description = "Agent auto-update immediately, patch and minor versions"
  }

  tags = local.common_tags
}

resource "aws_iot_thing_group" "AgentAutoUpdateMinorDaily" {
  name = "AgentAutoUpdateMinorDaily"

  parent_group_name = aws_iot_thing_group.AgentAutoUpdateMinor.name

  properties {
    attribute_payload {
      attributes = {
        autoUpdate = "minor"
        updateType = "daily"
      }
    }
    description = "Agent auto-update daily, patch and minor versions"
  }

  tags = local.common_tags
}

resource "aws_iot_thing_group" "AgentAutoUpdateMinorWeekly" {
  name = "AgentAutoUpdateMinorWeekly"

  parent_group_name = aws_iot_thing_group.AgentAutoUpdateMinor.name

  properties {
    attribute_payload {
      attributes = {
        autoUpdate = "minor"
        updateType = "weekly"
      }
    }
    description = "Agent auto-update weekly, patch and minor versions"
  }

  tags = local.common_tags
}


# Patch versions - agent auto update groups
# ----------------------------------------------------------------
resource "aws_iot_thing_group" "AgentAutoUpdateMajorASAP" {
  name = "AgentAutoUpdateMajorASAP"

  parent_group_name = aws_iot_thing_group.AgentAutoUpdateMajor.name

  properties {
    attribute_payload {
      attributes = {
        autoUpdate = "major"
        updateType = "asap"
      }
    }
    description = "Agent auto-update immediately, patch, minor, and major versions"
  }

  tags = local.common_tags
}

resource "aws_iot_thing_group" "AgentAutoUpdateMajorDaily" {
  name = "AgentAutoUpdateMajorDaily"

  parent_group_name = aws_iot_thing_group.AgentAutoUpdateMajor.name

  properties {
    attribute_payload {
      attributes = {
        autoUpdate = "major"
        updateType = "daily"
      }
    }
    description = "Agent auto-update daily, patch, minor, and major versions"
  }

  tags = local.common_tags
}

resource "aws_iot_thing_group" "AgentAutoUpdateMajorWeekly" {
  name = "AgentAutoUpdateMajorWeekly"

  parent_group_name = aws_iot_thing_group.AgentAutoUpdateMajor.name

  properties {
    attribute_payload {
      attributes = {
        autoUpdate = "major"
        updateType = "weekly"
      }
    }
    description = "Agent auto-update weekly, patch, minor, and major versions"
  }

  tags = local.common_tags
}


# resource "aws_iot_thing_group_membership" "example" {
#   thing_name       = "example-thing"
#   thing_group_name = "example-group"

#   override_dynamic_group = true
# }
