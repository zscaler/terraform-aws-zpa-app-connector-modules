# Changelog

All notable changes to this project will be documented in this file.

### [1.7.1](https://github.com/zscaler/terraform-aws-zpa-app-connector-modules/compare/v1.7.0...v1.7.1) (2025-09-26)


### Bug Fixes

* improve module functionality and add comprehensive testing ([#27](https://github.com/zscaler/terraform-aws-zpa-app-connector-modules/issues/27)) ([3905a34](https://github.com/zscaler/terraform-aws-zpa-app-connector-modules/commit/3905a34c62508f45853578fea857430a5d9b1c75))

## [1.7.0](https://github.com/zscaler/terraform-aws-zpa-app-connector-modules/compare/v1.6.0...v1.7.0) (2025-09-24)


### Features

* update ZPA provider constraints and version profile defaults ([#26](https://github.com/zscaler/terraform-aws-zpa-app-connector-modules/issues/26)) ([452d712](https://github.com/zscaler/terraform-aws-zpa-app-connector-modules/commit/452d712b6dd313603781c8c0941ccc6fa2ec03ac))

## [1.6.0](https://github.com/zscaler/terraform-aws-zpa-app-connector-modules/compare/v1.5.1...v1.6.0) (2025-09-24)


### Features

* add support for custom KMS key for EBS volume encryption ([#25](https://github.com/zscaler/terraform-aws-zpa-app-connector-modules/issues/25)) ([544b5cf](https://github.com/zscaler/terraform-aws-zpa-app-connector-modules/commit/544b5cf0df4fa8a0cc7e3c5ade5c058877558fe4))
* **zpa provider:** Removed version constraints to allow latest provider versions
* **app connector group:** Changed default `app_connector_group_version_profile_id` from "2" to "0" (Default version profile)

### [1.5.1](https://github.com/zscaler/terraform-aws-zpa-app-connector-modules/compare/v1.5.0...v1.5.1) (2025-04-07)


### Bug Fixes

* Updated AWS provider version to v5.94.x ([#23](https://github.com/zscaler/terraform-aws-zpa-app-connector-modules/issues/23)) ([a7f73e8](https://github.com/zscaler/terraform-aws-zpa-app-connector-modules/commit/a7f73e83e904b70e81938407dcc387e635b848e6))

### Bug Fixes

## [1.5.1](https://github.com/zscaler/terraform-aws-zpa-app-connector-modules/compare/v1.4.0...v1.5.1) (2025-04-07)
* Updated AWS provider version to v5.94.x - (#PR21)[https://github.com/zscaler/terraform-aws-zpa-app-connector-modules/pull/21]
* Updated README with instructions for ZPA Terraform provider authentication via Legacy API framework and OneAPI - (#PR21)[https://github.com/zscaler/terraform-aws-zpa-app-connector-modules/pull/21]
* enforce imdsv2 only by default for new deployments (#PR20)[https://github.com/zscaler/terraform-aws-zpa-app-connector-modules/pull/20]

### Features

## [1.5.0](https://github.com/zscaler/terraform-aws-zpa-app-connector-modules/compare/v1.4.0...v1.5.0) (2024-07-25)
* Updated all modules to new Zscaler RHEL9 Images

* Updated all modules to new Zscaler RHEL9 Images ([#18](https://github.com/zscaler/terraform-aws-zpa-app-connector-modules/issues/18)) ([af49827](https://github.com/zscaler/terraform-aws-zpa-app-connector-modules/commit/af498271c1e521c41027e9b915325317afd71876))

## [1.4.0](https://github.com/zscaler/terraform-aws-zpa-app-connector-modules/compare/v1.3.1...v1.4.0) (2024-07-20)


### Features

* improve launch template for ASG AWS module ([#15](https://github.com/zscaler/terraform-aws-zpa-app-connector-modules/issues/15)) ([2efdd33](https://github.com/zscaler/terraform-aws-zpa-app-connector-modules/commit/2efdd336b5e8c46e16143469594dad6c9a4a9c8b))

### [1.3.1](https://github.com/zscaler/terraform-aws-zpa-app-connector-modules/compare/v1.3.0...v1.3.1) (2023-03-16)


### Bug Fixes

* marketplace ami update ([e0c38ec](https://github.com/zscaler/terraform-aws-zpa-app-connector-modules/commit/e0c38ecefe61625b6cbe50ba5181700cbf886713))

## [1.3.0](https://github.com/zscaler/terraform-aws-zpa-app-connector-modules/compare/v1.2.0...v1.3.0) (2023-02-12)


### Features

* add support for al2 t2.micro ec2 ([bc21924](https://github.com/zscaler/terraform-aws-zpa-app-connector-modules/commit/bc21924df26fd38707b5bac83c1b0219ddb5318b))

## [1.2.0](https://github.com/zscaler/terraform-aws-zpa-app-connector-modules/compare/v1.1.1...v1.2.0) (2023-02-12)


### Features

* add support for al2 t2.micro ec2 ([b54c044](https://github.com/zscaler/terraform-aws-zpa-app-connector-modules/commit/b54c044eac7599204bf6f304c92980e91eaa61d1))


### Bug Fixes

* validation of all supported instance types ([ba502dc](https://github.com/zscaler/terraform-aws-zpa-app-connector-modules/commit/ba502dc5a145a9bd1bbc21e881dc020a5758e391))
* validation of all supported instance types ([8580b12](https://github.com/zscaler/terraform-aws-zpa-app-connector-modules/commit/8580b121b04563c01d5a01c6dbafca5a00e9352d))

### [1.1.1](https://github.com/zscaler/terraform-aws-zpa-app-connector-modules/compare/v1.1.0...v1.1.1) (2023-02-10)


### Bug Fixes

* Amazon Linux 2 userdata permission ([1fe7a3a](https://github.com/zscaler/terraform-aws-zpa-app-connector-modules/commit/1fe7a3a298ce3ff8f1a4d1c17ec25c014c36e1dd))
* tflint and vpc resource selections ([f96fc1b](https://github.com/zscaler/terraform-aws-zpa-app-connector-modules/commit/f96fc1b70a9365041244919772ed6e206052ae78))
* Update CI Python version to 3.11 ([4aff607](https://github.com/zscaler/terraform-aws-zpa-app-connector-modules/commit/4aff60777d2a7db1f0ce7fa36007c3494c5803b9))

### [1.1.1](https://github.com/zscaler/terraform-aws-zpa-app-connector-modules/compare/v1.1.0...v1.1.1) (2023-01-24)


### Bug Fixes

* Amazon Linux 2 userdata permission ([1fe7a3a](https://github.com/zscaler/terraform-aws-zpa-app-connector-modules/commit/1fe7a3a298ce3ff8f1a4d1c17ec25c014c36e1dd))
* Update CI Python version to 3.11 ([4aff607](https://github.com/zscaler/terraform-aws-zpa-app-connector-modules/commit/4aff60777d2a7db1f0ce7fa36007c3494c5803b9))

## [1.1.0](https://github.com/zscaler/terraform-aws-zpa-app-connector-modules/compare/v1.0.1...v1.1.0) (2022-10-21)


### Features

* add support for Amazon Linux 2 AMI ([0aa8fd8](https://github.com/zscaler/terraform-aws-zpa-app-connector-modules/commit/0aa8fd87e554cb878ccf06b3c505018a9cd07930))

## 1.0.0 (2022-10-07)


### Features

* add ac asg module ([8def069](https://github.com/zscaler/terraform-aws-zpa-app-connector-modules/commit/8def06909b7ed7238441524c77a0842a0c8ece23))
* add ac deployment ([8b8a924](https://github.com/zscaler/terraform-aws-zpa-app-connector-modules/commit/8b8a924f3ba6645919ea4aca6086472294f85a16))
* add ac vm public ip output ([a0cdcc9](https://github.com/zscaler/terraform-aws-zpa-app-connector-modules/commit/a0cdcc95e439909139a6ec394659ce437bc43809))
* add ac_asg deployment ([c9c4548](https://github.com/zscaler/terraform-aws-zpa-app-connector-modules/commit/c9c4548ca6624547bed5106fda1e534621fc3581))
* add base deployment type ([5690e36](https://github.com/zscaler/terraform-aws-zpa-app-connector-modules/commit/5690e36be620d4aed9686192942bcffb0a7dc8a4))
* add base_ac deployment ([6813bd4](https://github.com/zscaler/terraform-aws-zpa-app-connector-modules/commit/6813bd48b2b923f753f669a621be79f324641e16))
* add base_ac_asg deployment ([f9f996c](https://github.com/zscaler/terraform-aws-zpa-app-connector-modules/commit/f9f996c7af1320fb98616aaa15e621ed4352ffdd))
* add base_ac_zpa deployment ([a29b49b](https://github.com/zscaler/terraform-aws-zpa-app-connector-modules/commit/a29b49bf05c569df5ea6f62a456f4d9351ab6f96))
* add network module ([4172ff5](https://github.com/zscaler/terraform-aws-zpa-app-connector-modules/commit/4172ff56c804aa94abbade27ec4fd5124aa13648))
* add pre-commit hooks ([9a2f32e](https://github.com/zscaler/terraform-aws-zpa-app-connector-modules/commit/9a2f32e794bc2e157a33d93c34ddeb36be6c29bc))
* add zpa app connector group module ([c694d80](https://github.com/zscaler/terraform-aws-zpa-app-connector-modules/commit/c694d80a9af356ff003187249fce29879d79383b))
* add zsac script for ac deployment assistance ([26ff4f8](https://github.com/zscaler/terraform-aws-zpa-app-connector-modules/commit/26ff4f8465c08e67a088718b80294d704bd8319f))
* bastion module rework ([2c112fb](https://github.com/zscaler/terraform-aws-zpa-app-connector-modules/commit/2c112fb4f09ca59123862c9768fda88ba6553d1b))
* deployment types to use zpa provider ([60801ba](https://github.com/zscaler/terraform-aws-zpa-app-connector-modules/commit/60801badd7b6024d50d8292ea5f808c079396512))
* network module conditional creates ([87e3dab](https://github.com/zscaler/terraform-aws-zpa-app-connector-modules/commit/87e3dabef386ca786aea9e6c29a5ab989ae8f586))


### Bug Fixes

* change AL2 AMI to pull from AWS parameter store ([#2](https://github.com/zscaler/terraform-aws-zpa-app-connector-modules/issues/2)) ([4d26641](https://github.com/zscaler/terraform-aws-zpa-app-connector-modules/commit/4d266410372b3caee6595bb5c19b5328d35b0a54))
* IAM SSM removal ([5c150dd](https://github.com/zscaler/terraform-aws-zpa-app-connector-modules/commit/5c150dde136af2888f93524244342b45f54913b3))
* tflint cleanup ([3f471dc](https://github.com/zscaler/terraform-aws-zpa-app-connector-modules/commit/3f471dc6b2a16ebd02be48afec518417663bae5b))
* tflint remove undeclared variable ([8acf56a](https://github.com/zscaler/terraform-aws-zpa-app-connector-modules/commit/8acf56abd2070fc6c339aea3f4e8822960ce14c5))
* variable name cleanup ([92c0625](https://github.com/zscaler/terraform-aws-zpa-app-connector-modules/commit/92c0625b4560433fff2eba41bb210b7deb136797))
* zsac errors and asg target variable name ([179a2af](https://github.com/zscaler/terraform-aws-zpa-app-connector-modules/commit/179a2afde976fd11db72c8f7adc9832ae74fd9a4))
* **zscanner:** Upgraded to v1.2.0 ([dc08739](https://github.com/zscaler/terraform-aws-zpa-app-connector-modules/commit/dc08739fd70a1c28e785a9c8a5c600adfb94256f))
