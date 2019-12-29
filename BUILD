# Copyright 2017-present The Material Motion Authors. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# Description:
# Motion interchange format.

load("@bazel_skylib//rules:build_test.bzl", "build_test")
load("@build_bazel_rules_apple//apple:ios.bzl", "ios_ui_test_suite")
load("@build_bazel_rules_apple//apple/testing/default_runner:ios_test_runner.bzl", "ios_test_runner")
load("@build_bazel_rules_swift//swift:swift.bzl", "swift_library")
load("@bazel_ios_warnings//:strict_warnings_objc_library.bzl", "strict_warnings_objc_library")
load("@bazel_apple_framework_relative_headers//:apple_framework_relative_headers.bzl", "apple_framework_relative_headers")

licenses(["notice"])  # Apache 2.0

exports_files(["LICENSE"])

strict_warnings_objc_library(
    name = "MotionInterchange",
    srcs = glob([
        "src/*.m",
        "src/private/*.m",
    ]),
    hdrs = glob([
        "src/*.h",
        "src/private/*.h",
    ]),
    sdk_frameworks = [
        "CoreGraphics",
        "Foundation",
        "QuartzCore",
        "UIKit",
    ],
    enable_modules = 1,
    module_name = "MotionInterchange",
    includes = ["src"],
    visibility = ["//visibility:public"],
    deps = [
        ":MotionInterchangeFrameworkHeaders",
    ],
)

apple_framework_relative_headers(
    name = "MotionInterchangeFrameworkHeaders",
    hdrs = glob([
        "src/*.h",
    ]),
    framework_name = "MotionInterchange",
)

build_test(
    name = "BuildTest",
    targets = [
        ":MotionInterchange",
    ],
)

swift_library(
    name = "UnitTestsSwiftLib",
    srcs = glob([
        "tests/unit/*.swift",
    ]),
    deps = [":MotionInterchange"],
    visibility = ["//visibility:private"],
)

objc_library(
    name = "UnitTestsLib",
    srcs = glob([
        "tests/unit/*.m",
    ]),
    deps = [":MotionInterchange"],
    visibility = ["//visibility:private"],
)

ios_test_runner(
    name = "IPHONE_7_PLUS_IN_10_3",
    device_type = "iPhone 7 Plus",
    os_version = "10.3",
)

ios_test_runner(
    name = "IPHONE_X_IN_11_4",
    device_type = "iPhone X",
    os_version = "11.4",
)

ios_test_runner(
    name = "IPHONE_XS_MAX_IN_12_2",
    device_type = "iPhone Xs Max",
    os_version = "12.2",
)

ios_ui_test_suite(
    name = "UnitTests",
    deps = [
      ":UnitTestsLib",
      ":UnitTestsSwiftLib"
    ],
    test_host = "@bazel_test_host_apple//test_host",
    minimum_os_version = "9.0",
    timeout = "moderate",
    runners = [
        ":IPHONE_7_PLUS_IN_10_3",
        ":IPHONE_X_IN_11_4",
        ":IPHONE_XS_MAX_IN_12_2",
    ],
)
