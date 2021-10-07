from RPA.Robocorp.WorkItems import State, WorkItems

library = WorkItems()

def process_and_set_state():
    library.get_input_work_item()
    library.release_input_work_item(State.DONE)
    print(library.current.state)  # would print "State.DONE"

process_and_set_state()
