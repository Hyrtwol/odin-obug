package obug

import win32 "core:sys/windows"

wanted_code_page := win32.CODEPAGE.UTF8

@(init)
init_console :: proc "contextless" () {
	cpi, cpo := win32.GetConsoleCP(), win32.GetConsoleOutputCP()
	if cpi != wanted_code_page {
		win32.SetConsoleCP(wanted_code_page)
	}
	if cpo != wanted_code_page {
		win32.SetConsoleOutputCP(wanted_code_page)
	}
}
