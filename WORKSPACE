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

load("@bazel_tools//tools/build_defs/repo:git.bzl", "git_repository")
load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_file")

git_repository(
    name = "bazel_workspace_apple",
    remote = "https://github.com/jverkoey/bazel-workspace-apple.git",
    commit = "1398d78f68b3401e45d73e437063007e5215ff05",  # Dec 29, 2019
    shallow_since = "1577916902 -0500",  # Recommended by bazel.
)

load("@bazel_workspace_apple//apple:repositories.bzl", "apple_workspace_dependencies")
apple_workspace_dependencies()
