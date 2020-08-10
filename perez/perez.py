import os
from flask import Flask

def create_app():
    """Create and configure an instance of the Flask application."""
    app = Flask(__name__)
    app.config.from_mapping(
        # a default secret that should be overridden by instance config
        SECRET_KEY=os.getenv("SECRET_KEY", "notreallyasecret")
    )

    # ensure the instance folder exists
    try:
        os.makedirs(app.instance_path)
    except OSError:
        pass

    # apply the blueprints to the app
    from perez import about, contact, index, projects, resume
    app.register_blueprint(about.bp)
    app.register_blueprint(contact.bp)
    app.register_blueprint(index.bp)
    app.register_blueprint(projects.bp)
    app.register_blueprint(resume.bp)

    return app

if __name__ == "__main__":
    app = create_app()
    app.run(host='0.0.0.0')
