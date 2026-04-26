//go:build unix

package userprompt

import "syscall"

// detachSysProcAttr returns a SysProcAttr that detaches the spawned process
// from this process group, so it survives our exit.
func detachSysProcAttr() *syscall.SysProcAttr {
	return &syscall.SysProcAttr{Setsid: true}
}
