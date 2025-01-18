from flask import Blueprint, request, jsonify
from src.image_analyzer import analyze
from werkzeug.utils import secure_filename
import os
import redis
import uuid

blueprint = Blueprint('api', __name__)

# Configurazioni
UPLOAD_FOLDER = os.getenv('UPLOAD_FOLDER', 'uploads')
UPLOAD_FOLDER_NAME = os.getenv('UPLOAD_FOLDER_NAME', 'uploads')
os.makedirs(UPLOAD_FOLDER, exist_ok=True)

# Configurazione Redis
redis_client = redis.StrictRedis(
    host=os.getenv('REDIS_HOST', 'localhost'),
    port=int(os.getenv('REDIS_PORT', 6379)),
    db=int(os.getenv('REDIS_DB', 0)),
    decode_responses=True
)
REDIS_COUNTER_KEY = 'image_id_counter'
REDIS_PHOTO_KEY_PREFIX = 'photos:'  # Prefisso per salvare le foto associate a un lottoid

@blueprint.route('/analyze', methods=['POST'])
def analyze_image():
    if 'image' not in request.files:
        return jsonify({'error': 'No image part in the request'}), 400

    file = request.files['image']

    if file.filename == '':
        return jsonify({'error': 'No selected file'}), 400

    lottoid = request.form.get('lottoid')
    if not lottoid:
        return jsonify({'error': 'lottoid is required'}), 400

    # Genera un ID incrementale per l'immagine
    image_id = redis_client.incr(REDIS_COUNTER_KEY)
    filename = f"{lottoid}_{image_id}.png"
    filepath = os.path.join(UPLOAD_FOLDER, filename)

    file.save(filepath)

    try:
        result = analyze(filepath)

        # Salva il percorso dell'immagine associata al lottoid in Redis
        redis_client.rpush(f"{REDIS_PHOTO_KEY_PREFIX}{lottoid}", filename)

        return jsonify({'result': result, 'filename': filename})
    except Exception as e:
        return jsonify({'error': str(e)}), 500
    finally:
        os.remove(filepath)

@blueprint.route('/photos', methods=['GET'])
def get_photos():
    lottoid = request.args.get('lottoid')
    if not lottoid:
        return jsonify({'error': 'lottoid is required'}), 400

    # Recupera le immagini associate al lottoid
    photo_list = redis_client.lrange(f"{REDIS_PHOTO_KEY_PREFIX}{lottoid}", 0, -1)

    if not photo_list:
        return jsonify({'error': 'No photos found for the given lottoid'}), 404

    # Genera gli URL delle immagini
    photo_urls = [f"/{UPLOAD_FOLDER_NAME}/{photo}" for photo in photo_list]

    return jsonify({'photos': photo_urls})
