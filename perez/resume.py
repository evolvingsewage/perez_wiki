from flask import Blueprint, render_template

bp = Blueprint("resume", __name__, url_prefix="/resume")

@bp.route('/')
def resume():
    return render_template("resume.html")
