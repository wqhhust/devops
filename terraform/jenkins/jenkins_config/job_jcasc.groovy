// https://jenkinsci.github.io/job-dsl-plugin/#path/multibranchPipelineJob
multibranchPipelineJob('example') {
    branchSources {
        git {
            id('1234567777')
            remote('https://github.com/wqhhust/javatest.git')
            includes('m*')
        }
    }
    orphanedItemStrategy {
        discardOldItems {
            numToKeep(20)
        }
    }
}
