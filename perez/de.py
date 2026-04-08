from flask import Blueprint, render_template

bp = Blueprint("de", __name__, url_prefix="/de")

@bp.route('/')
def index():
    return render_template("de/index.html")

@bp.route('/about')
def about():
    return render_template("de/about.html")

@bp.route('/resume')
def resume():
    return render_template("de/resume.html")

@bp.route('/projects')
def projects():
    return render_template("de/projects.html")

@bp.route('/contact')
def contact():
    return render_template("de/contact.html")
