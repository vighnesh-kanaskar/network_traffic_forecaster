from network_monitor import monitor

def get_current_snapshot():
    return monitor.get_snapshot()


def get_live_traffic():

    snapshot = monitor.get_snapshot()

    return snapshot["recent_traffic"]