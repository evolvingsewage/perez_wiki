from perez.perez import create_app as app

if __name__ == "__main__":
    app.run()
else:
    gunicorn_app = app()
