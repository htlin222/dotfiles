package branchguard

import (
	"reflect"
	"testing"
)

func TestCheckCommand(t *testing.T) {
	tests := []struct {
		name  string
		cmd   string
		block bool
	}{
		// Previously-covered direct forms
		{"reset hard", "git reset --hard", true},
		{"reset hard ref", "git reset --hard HEAD~1", true},
		{"push force", "git push --force", true},
		{"push -f", "git push -f origin feat", true},
		{"push force-with-lease stays blocked", "git push --force-with-lease", true},
		{"clean -f", "git clean -f", true},
		{"checkout dot", "git checkout .", true},
		{"branch -D main", "git branch -D main", true},
		{"branch -d master", "git branch -d master", true},
		{"push delete refspec", "git push origin :main", true},

		// Bypasses that must now be caught
		{"cd then reset", "cd x && git reset --hard", true},
		{"git -C", "git -C /p reset --hard", true},
		{"git -c kv", "git -c core.pager=cat push --force", true},
		{"git-dir eq", "git --git-dir=/p/.git --work-tree=/p reset --hard", true},
		{"git-dir split", "git --git-dir /p/.git reset --hard", true},
		{"rtk wrapper", "rtk git push --force", true},
		{"env assign", "FOO=1 git clean -fd", true},
		{"clean -df cluster", "git clean -df", true},
		{"clean --force", "git clean --force", true},
		{"command wrapper", "command git reset --hard", true},
		{"sudo -E wrapper", "sudo -E git reset --hard", true},
		{"env wrapper with assign", "env GIT_DIR=x git reset --hard", true},
		{"nohup time chain", "nohup time git push -f", true},
		{"after semicolon", "echo hi; git reset --hard", true},
		{"after or", "false || git reset --hard", true},
		{"after pipe", "yes | git clean -f", true},
		{"subshell", "(cd x && git reset --hard)", true},
		{"absolute git path", "/usr/bin/git reset --hard", true},
		{"push +refspec", "git push origin +main", true},
		{"push --delete main", "git push origin --delete main", true},
		{"push -uf cluster", "git push -uf origin feat", true},

		// New whole-tree discards
		{"checkout -- dot", "git checkout -- .", true},
		{"restore dot", "git restore .", true},
		{"restore worktree dot", "git restore --worktree .", true},
		{"restore staged+worktree dot", "git restore --staged --worktree .", true},
		{"restore -SW dot", "git restore -SW .", true},
		{"restore root pathspec", "git restore :/", true},

		// Must be allowed
		{"echo quoted", `echo "git reset --hard"`, false},
		{"echo quoted with operator", `echo "a && git reset --hard"`, false},
		{"gh pr create", "gh pr create --title x", false},
		{"git status", "git status", false},
		{"git push plain", "git push origin feat", false},
		{"git push -u", "git push -u origin feat", false},
		{"reset soft", "git reset --soft HEAD~1", false},
		{"clean dry run", "git clean -n", false},
		{"checkout branch", "git checkout main", false},
		{"checkout file", "git checkout -- src/a.go", false},
		{"restore staged only", "git restore --staged .", false},
		{"restore one file", "git restore src/a.go", false},
		{"branch -d feature", "git branch -d feature", false},
		{"branch -d main-prefixed name", "git branch -d main-feature", false},
		{"commit msg mentions reset", `git commit -m "avoid git reset --hard"`, false},
		{"heredoc body only first line scanned", "git commit -F- <<'EOF'\ngit reset --hard\nEOF", false},
		{"redirect not separator", "git status 2>&1", false},
		{"empty", "", false},
		{"grep for git", "grep -r 'git push --force' .", false},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			got := checkCommand(tt.cmd) != ""
			if got != tt.block {
				t.Errorf("checkCommand(%q) blocked=%v, want %v (reason=%q)",
					tt.cmd, got, tt.block, checkCommand(tt.cmd))
			}
		})
	}
}

func TestSplitSegments(t *testing.T) {
	tests := []struct {
		in   string
		want []string
	}{
		{"a && b", []string{"a ", " b"}},
		{"a || b; c | d", []string{"a ", " b", " c ", " d"}},
		{`echo "x && y"`, []string{`echo "x && y"`}},
		{`echo 'x; y'`, []string{`echo 'x; y'`}},
		{"a 2>&1 | b", []string{"a 2>&1 ", " b"}},
	}
	for _, tt := range tests {
		if got := splitSegments(tt.in); !reflect.DeepEqual(got, tt.want) {
			t.Errorf("splitSegments(%q) = %q, want %q", tt.in, got, tt.want)
		}
	}
}

func TestGitArgs(t *testing.T) {
	tests := []struct {
		in   []string
		want []string
	}{
		{[]string{"git", "status"}, []string{"status"}},
		{[]string{"git", "-C", "/p", "reset", "--hard"}, []string{"reset", "--hard"}},
		{[]string{"FOO=1", "rtk", "git", "--no-pager", "log"}, []string{"log"}},
		{[]string{"echo", "git", "reset"}, nil},
		{[]string{"gh", "pr", "create"}, nil},
	}
	for _, tt := range tests {
		if got := gitArgs(tt.in); !reflect.DeepEqual(got, tt.want) {
			t.Errorf("gitArgs(%q) = %q, want %q", tt.in, got, tt.want)
		}
	}
}
