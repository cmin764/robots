import time

from RPA.Windows import Windows


lib_win = Windows()

TIMEOUT = 5


def main():
    start = time.time()
    lib_win.set_global_timeout(TIMEOUT)
    try:
        lib_win.control_window("SOMETHIG", timeout=TIMEOUT)
    except Exception as exc:
        print(exc)
    print("Finished in: ", time.time() - start)


if __name__ == "__main__":
    main()
