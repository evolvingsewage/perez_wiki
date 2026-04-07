from flask import Blueprint, render_template

bp = Blueprint("contact", __name__, url_prefix="/contact")

@bp.route('/')
def about():
    return render_template("contact.html")
