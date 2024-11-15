from contextlib import closing
import sqlite3


def retrieve_api_key(scope):
    headers = scope.get('headers', [])

    for (name, value) in headers:
        if name.decode('utf-8').lower() == 'authorization':
            token = value.decode('utf-8')
            if token.startswith('Bearer '):
                return token[7:]
            return token

    return None


def verify_api_key(api_key):
    if not api_key:
        return False

    with closing(sqlite3.connect('db/webui.db')) as conn:
        with closing(conn.cursor()) as cursor:
            result = cursor.execute(
                "SELECT * FROM user WHERE api_key = ? AND (role = 'user' OR role = 'admin')",
                (api_key,)
            )
            return result.fetchone() is not None


async def app(scope, _, send):
    assert scope['type'] == 'http'

    api_key = retrieve_api_key(scope)

    await send({
        'type': 'http.response.start',
        'status': 200 if verify_api_key(api_key) else 401,
    })
    await send({
        'type': 'http.response.body',
    })
