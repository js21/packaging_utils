package {"language-pack-en":
    ensure => "installed"
    }

package { "less", "more", "emacs-nox":
	ensure => "installed"
	}

include apt