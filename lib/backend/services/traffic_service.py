from services.network_service import load_data


def get_traffic():
    data = load_data()
    return data["traffic"]