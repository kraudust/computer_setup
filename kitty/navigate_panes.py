from kittens.tui.handler import result_handler


def main(args):
    pass


@result_handler(no_ui=True)
def handle_result(args, result, target_window_id, boss):
    tab = boss.active_tab
    if tab is None:
        return

    direction = args[1]
    if tab.current_layout.name == 'stack':
        if direction == 'left':
            tab.previous_window()
        else:
            tab.next_window()
    else:
        tab.neighboring_window(direction)
