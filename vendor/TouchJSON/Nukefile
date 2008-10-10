;;
;; Nukefile for TouchJSON
;;
;; Commands:
;;	nuke 		- builds TouchJSON as a framework
;;	nuke test	- runs the unit tests in the NuTests directory
;;	nuke install	- installs TouchJSON in /Library/Frameworks
;;	nuke clean	- removes build artifacts
;;	nuke clobber	- removes build artifacts and TouchJSON.framework
;;
;; The "nuke" build tool is installed with Nu (http://programming.nu)
;;

;; the @variables below are instance variables of a NukeProject.
;; for details, see tools/nuke in the Nu source distribution.

;; source files
(set @m_files     (filelist "^Source/Extensions/.*.m$"))
(@m_files 		  unionSet:(filelist "^Source/JSON/.*.m$"))

;; framework description
(set @framework "TouchJSON")
(set @framework_identifier   "com.toxicsoftware.touchjson")
(set @framework_creator_code "????")

(set @cflags "-g -I Source/Extensions -I Source/JSON")
(set @ldflags "-framework Cocoa")

(compilation-tasks)
(framework-tasks)

(task "clobber" => "clean" is
      (SH "rm -rf #{@framework_dir}")) ;; @framework_dir is defined by the nuke framework-tasks macro

(task "default" => "framework")

(task "install" => "framework" is
      (SH "sudo rm -rf /Library/Frameworks/#{@framework}.framework")
      (SH "ditto #{@framework}.framework /Library/Frameworks/#{@framework}.framework"))

(task "test" => "framework" is
      (SH "nutest NuTests/test_*.nu"))
