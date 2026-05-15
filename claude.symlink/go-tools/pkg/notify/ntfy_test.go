package notify

import "testing"

func TestAppleScriptString(t *testing.T) {
	cases := []struct {
		in, want string
	}{
		{`hello`, `"hello"`},
		{`with "quotes"`, `"with \"quotes\""`},
		{`back\slash`, `"back\\slash"`},
		{`both "and" \ here`, `"both \"and\" \\ here"`},
		{``, `""`},
		{"line1\nline2", "\"line1\nline2\""},
	}
	for _, tc := range cases {
		if got := appleScriptString(tc.in); got != tc.want {
			t.Errorf("appleScriptString(%q) = %q, want %q", tc.in, got, tc.want)
		}
	}
}
