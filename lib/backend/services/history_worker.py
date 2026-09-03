import threading
import time

from database import save_history
from services.network_service import get_current_snapshot
from services.forecast_service import get_forecast


running = False


def start_history_worker():

    global running

    if running:
        return

    running = True

    thread = threading.Thread(
        target=_worker,
        daemon=True
    )

    thread.start()


def _worker():

    while running:

        try:

            snapshot = get_current_snapshot()

            forecast = get_forecast()

            save_history(
                current_state=forecast["current_state"],
                predicted_state=forecast["predicted_state"],
                confidence=forecast["confidence"],
                risk=forecast["risk"],
                packets=snapshot["packets"],
                packets_per_second=snapshot["packets_per_second"],
                unique_ips=snapshot["unique_ips"],
                flows=snapshot["flows"]
            )

        except Exception as error:
            print(
                "History worker error:",
                error
            )

        time.sleep(10)