local runUnitTests(pkgname, tag) = {
    name: "run-unit-tests-" + tag,
    kind: "pipeline",
    type: "docker",
    trigger: {branch: [tag]},

    steps: [{
        name: "run-unit-tests",
        image: "proget.hunterwittenborn.com/docker/makedeb/" + pkgname + ":ubuntu-jammy",
        environment: {
            release_type: tag,
            pkgname: pkgname
        },
        commands: [
            ".drone/scripts/install-deps.sh",
            "sudo chown 'makedeb:makedeb' ../ -R",
            ".drone/scripts/run-unit-tests.sh"
        ]
    }]
};

local createTag(tag) = {
    name: "create-tag-" + tag,
    kind: "pipeline",
    type: "docker",
    trigger: {branch: [tag]},
    depends_on: ["run-unit-tests-" + tag],
    steps: [{
        name: tag,
        image: "proget.hunterwittenborn.com/docker/makedeb/makedeb:ubuntu-jammy",
        environment: {
            github_api_key: {from_secret: "github_api_key"}
        },
        commands: [
            ".drone/scripts/create_tag.sh"
        ]
    }]
};

local userRepoPublish(pkgname, tag, user_repo) = {
    name: user_repo + "-publish-" + tag,
    kind: "pipeline",
    type: "docker",
    trigger: {branch: [tag]},
    depends_on: ["create-tag-" + tag],
    steps: [{
        name: pkgname,
        image: "proget.hunterwittenborn.com/docker/makedeb/" + pkgname + ":ubuntu-jammy",
        environment: {
            ssh_key: {from_secret: "ssh_key"},
            package_name: pkgname,
            release_type: tag,
            target_repo: user_repo
        },
        commands: [
            ".drone/scripts/install-deps.sh",
            ".drone/scripts/user-repo.sh"
        ]
    }]
};

local buildAndPublish(pkgname, tag) = {
    name: "build-and-publish-" + tag,
    kind: "pipeline",
    type: "docker",
    trigger: {branch: [tag]},
    depends_on: ["mpr-publish-" + tag],
    steps: [
        {
            name: "build-debian-package",
            image: "proget.hunterwittenborn.com/docker/makedeb/" + pkgname + ":ubuntu-jammy",
            environment: {
                release_type: tag,
                pkgname: pkgname
            },
            commands: [
                ".drone/scripts/install-deps.sh",
                "sudo chown 'makedeb:makedeb' ../ -R",
                ".drone/scripts/build.sh"
            ]
        },

        {
            name: "publish-proget",
            image: "proget.hunterwittenborn.com/docker/makedeb/" + pkgname + ":ubuntu-jammy",
            environment: {proget_api_key: {from_secret: "proget_api_key"}},
            commands: [
                ".drone/scripts/install-deps.sh",
                ".drone/scripts/publish.py"
            ]
        }
    ]
};


local sendBuildNotification(tag) = {
    name: "send-build-notification-" + tag,
    kind: "pipeline",
    type: "docker",
    trigger: {
        branch: [tag],
        status: ["success", "failure"]
    },
    depends_on: ["build-and-publish-" + tag],
    steps: [{
        name: "send-notification",
        image: "proget.hunterwittenborn.com/docker/hwittenborn/drone-matrix",
        settings: {
            username: "drone",
            password: {from_secret: "matrix_api_key"},
            homeserver: "https://matrix.hunterwittenborn.com",
            room: "#makedeb-ci-logs:hunterwittenborn.com"
        }
    }]
};

[
    runUnitTests("makedeb", "stable"),
    runUnitTests("makedeb-beta", "beta"),
    runUnitTests("makedeb-alpha", "alpha"),

    createTag("stable"),
    createTag("beta"),
    createTag("alpha"),

    userRepoPublish("makedeb", "stable", "mpr"),
    userRepoPublish("makedeb-beta", "beta", "mpr"),
    userRepoPublish("makedeb-alpha", "alpha", "mpr"),

    buildAndPublish("makedeb", "stable"),
    buildAndPublish("makedeb-beta", "beta"),
    buildAndPublish("makedeb-alpha", "alpha"),

    sendBuildNotification("stable"),
    sendBuildNotification("beta"),
    sendBuildNotification("alpha")
]

// vim: set syntax=typescript ts=4 sw=4 expandtab:
