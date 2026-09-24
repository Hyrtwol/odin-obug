package obug

import win32 "core:sys/windows"

WANTED_CODE_PAGE :: win32.CODEPAGE.UTF8

@(init)
init_console :: proc "contextless" () {
	cpi, cpo := win32.GetConsoleCP(), win32.GetConsoleOutputCP()
	if cpi != WANTED_CODE_PAGE {
		win32.SetConsoleCP(WANTED_CODE_PAGE)
	}
	if cpo != WANTED_CODE_PAGE {
		win32.SetConsoleOutputCP(WANTED_CODE_PAGE)
	}
}
