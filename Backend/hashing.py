from passlib.context import CryptContext
pwd_cxt = CryptContext(schemes=["bcrypt"], deprecated="auto")

class Hash:
    @staticmethod
    def bcrypt(password: str) -> str:
        # Optional: enforce max length to avoid silent truncation
        if len(password.encode('utf-8')) > 72:
            raise ValueError("Password must be 72 bytes or fewer")
        return pwd_cxt.hash(password)

    @staticmethod
    def verify(plain_password: str, hashed_password: str) -> bool:
        return pwd_cxt.verify(plain_password,hashed_password)


# how to install openapi.json:
# curl http://localhost:8080/openapi.json -o openapi.json
# npm install -g openapi-to-postmanv2
# openapi2postmanv2 -s openapi.json -o collection.json
