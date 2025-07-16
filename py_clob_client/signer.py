

class Signer:
    def __init__(self, private_key: str, chain_id: int):
        assert private_key is not None and chain_id is not None

        self.private_key = private_key
        # self.account = Account.from_key(private_key)
        self.chain_id = chain_id

    def address(self):
        # return self.account.address
        return "0x0000000000000000000000000000000000000000"

    def get_chain_id(self):
        return self.chain_id

    def sign(self, message_hash):
        """
        Signs a message hash
        """
        print("py-clob-client was called, it shouldn't be used directly.")

