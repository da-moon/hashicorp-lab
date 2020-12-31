job "batch" {
  datacenters = ["[[env "DC"]]"]
	type = "batch"
	constraint {
		attribute = "${attr.kernel.name}"
		value = "linux"
	}
	periodic {
		cron = "[[.batch.cron]]"
		// Do not allow overlapping runs.
		prohibit_overlap = true
	}
	group "batch" {
    count = "[[.batch.count]]"
		task "date" {
			driver = "raw_exec"
			config {
				command = "date"
			}
			resources {
				cpu  = "[[.batch.cpu]]"
				memory  = "[[.batch.ram]]"
			}
		}
		task "echo-for-loop" {
			driver = "raw_exec"
			config {
				command = "/bin/bash"
				args = [
					"-c",                               # next argument is a shell script
					"for i; do echo \"$i\" || exit; done",# for loop
					"_",                                # passed as $0 to the script
					"one", "two", "three"               # passed as $1, $2, and $3
				]
			}
			logs {
				max_files     = "[[.batch.logs_max_files]]"
				max_file_size = "[[.batch.logs_max_file_size]]"
			}
			resources {
				cpu  = "[[.batch.cpu]]"
				memory  = "[[.batch.ram]]"
			}
		}
		task "echo-function" {
			driver = "raw_exec"
			config {
				command = "/bin/bash"
				args = [
					"-c",                               # next argument is a shell script
					"echo $(date -u +%m-%d-%H-%M-%S) ", # function
					"_",                                # passed as $0 to the script
				]
			}
			logs {
				max_files     = "[[.batch.logs_max_files]]"
				max_file_size = "[[.batch.logs_max_file_size]]"
			}
			resources {
				cpu  = "[[.batch.cpu]]"
				memory  = "[[.batch.ram]]"
			}
		}
	}
}