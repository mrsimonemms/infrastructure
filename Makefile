# Copyright 2023 Simon Emms <simon@simonemms.com>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

CONFIG = config.yaml
ENVIRONMENT ?= dev

create-config:
	@yq eval-all '. as $$item ireduce ({}; . * $$item)' ./kubernetes/config.yaml ./kubernetes/${ENVIRONMENT}/config.yaml > ${CONFIG}
	@yq e -i '.hetzner_token = "${HCLOUD_TOKEN}"' ${CONFIG}
	@yq e -i '.cluster_name = "${ENVIRONMENT}"' ${CONFIG}
	@yq e -i '.public_ssh_key_path = "${PWD}/ssh/key.pub"' ${CONFIG}
	@yq e -i '.private_ssh_key_path = "${PWD}/ssh/key"' ${CONFIG}
.PHONY: create-config

cruft-update:
ifeq (,$(wildcard .cruft.json))
	@echo "Cruft not configured"
else
	@cruft check || cruft update --skip-apply-ask --refresh-private-variables
endif
.PHONY: cruft-update

deploy:
	@hetzner-k3s create --config ${CONFIG}
.PHONY: deploy

destroy:
	@hetzner-k3s delete --config ${CONFIG}
.PHONY: destroy
