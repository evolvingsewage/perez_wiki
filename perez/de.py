from flask import Blueprint, render_template

bp = Blueprint("de", __name__, url_prefix="/de")

@bp.route('/', strict_slashes=False)
def index():
    return render_template("de/index.html")

@bp.route('/about', strict_slashes=False)
def about():
    return render_template("de/about.html")

@bp.route('/resume', strict_slashes=False)
def resume():
    return render_template("de/resume.html")

@bp.route('/projects', strict_slashes=False)
def projects():
    return render_template("de/projects.html")

@bp.route('/contact', strict_slashes=False)
def contact():
    return render_template("de/contact.html")
