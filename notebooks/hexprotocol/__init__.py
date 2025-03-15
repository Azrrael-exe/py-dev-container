from typing import Callable


def checksum_calculator(payload: list[int]) -> int:
    sum_payload = sum([item for item in payload])
    return 0xFF - (sum_payload & 0xFF)


class HexProtocol:
    def __init__(
        self,
        header: int = 0x7E,
        package_length: int = 5,
        crc_calculator: Callable = checksum_calculator,
    ):
        self.__header = header
        self.__package_length = package_length
        self.__crc_calculator = crc_calculator

    def encode_message(
        self,
        data: dict,
        variable_map: dict,
    ) -> list[int]:
        payload = []

        inverse_variable_map = {v: k for k, v in variable_map.items()}

        for key, value in data.items():
            try:
                payload.append(inverse_variable_map[key])
                payload.append(value >> 24)
                payload.append(value >> 16)
                payload.append(value >> 8)
                payload.append(value & 0xFF)
            except KeyError:
                print(f"WARNING: Variable {key} not found in variable map skipping")
        if len(payload) == 0:
            raise ValueError("No valid variables found")

        payload.append(self.__crc_calculator(payload))
        return [self.__header] + [len(payload) // self.__package_length] + payload

    def decode_message(
        self,
        message: list[int],
        variable_map: dict,
    ) -> dict:
        if message[0] != self.__header:
            raise ValueError("Invalid message")
        length = message[1]
        payload = message[2:-1]
        if len(payload) != (length * self.__package_length):
            raise ValueError("Invalid payload length")
        checksum = message[-1]
        if checksum != self.__crc_calculator(payload):
            raise ValueError("Invalid checksum")

        decoded_message = {}

        packages = [
            payload[i : i + self.__package_length]
            for i in range(0, len(payload), self.__package_length)
        ]
        for package in packages:
            key = package[0]
            value = package[1] << 24 | package[2] << 16 | package[3] << 8 | package[4]
            decoded_message[variable_map.get(key, key)] = value
        return decoded_message
