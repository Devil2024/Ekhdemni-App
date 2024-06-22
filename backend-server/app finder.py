from flask import Flask, request, jsonify, render_template_string
import pandas as pd
import numpy as np
from sklearn.neighbors import NearestNeighbors
from haversine import haversine
from fuzzywuzzy import fuzz
import folium
import logging

app = Flask(__name__)

# Load data
car_repair_places = pd.read_excel('car_repair_places.xlsx')
electronics_repair_places = pd.read_excel('electronics_repair_places.xlsx')

# Configure logging
logging.basicConfig(level=logging.DEBUG)

@app.route('/nearest_repair_shops', methods=['POST'])
def nearest_repair_shops():
    data = request.json
    logging.debug(f'Received data: {data}')
    
    latitude = data['latitude']
    longitude = data['longitude']
    user_type_of_repair = data['type_of_repair']
    choice = data['choice']

    if choice == 1:
        repair_places = car_repair_places
        type_column_name = 'Type of repair'
    elif choice == 2:
        repair_places = electronics_repair_places
        type_column_name = 'Type of electronics'
    else:
        return jsonify({'error': 'Invalid choice'}), 400

    repair_places[type_column_name] = repair_places[type_column_name].astype(str)
    repair_places['type_similarity'] = repair_places[type_column_name].apply(
        lambda x: fuzz.partial_ratio(user_type_of_repair, x) if isinstance(x, str) else 0
    )

    num_neighbors = 10
    knn = NearestNeighbors(n_neighbors=num_neighbors).fit(np.radians(repair_places[['latitude', 'longitude']].values))
    distance, indices = knn.kneighbors(np.radians([[latitude, longitude]]))
    nearest_neighbors_indices = indices.flatten()
    nearest_neighbors_data = repair_places.iloc[nearest_neighbors_indices].copy()

    nearest_neighbors_data['distance'] = nearest_neighbors_data.apply(
        lambda row: haversine((latitude, longitude), (row['latitude'], row['longitude'])),
        axis=1
    )

    # Remove rows with NaN or infinite distances
    nearest_neighbors_data = nearest_neighbors_data.dropna(subset=['distance'])
    nearest_neighbors_data = nearest_neighbors_data[np.isfinite(nearest_neighbors_data['distance'])]

    filtered_data = repair_places[repair_places[type_column_name] == user_type_of_repair].copy()
    combined_data = pd.concat([filtered_data, nearest_neighbors_data])
    combined_data = combined_data.sort_values(by=['type_similarity', 'distance'])

    logging.debug(f'Combined data: {combined_data}')

    result = combined_data.to_dict(orient='records')
    for record in result:
        for key, value in record.items():
            if isinstance(value, float) and (np.isnan(value) or np.isinf(value)):
                logging.warning(f'Invalid value found: {key}={value}, setting to None')
                record[key] = None

    return jsonify(result)

@app.route('/map', methods=['POST'])
def generate_map():
    data = request.json
    latitude = data['latitude']
    longitude = data['longitude']
    user_type_of_repair = data['type_of_repair']
    choice = data['choice']

    if choice == 1:
        repair_places = car_repair_places
        type_column_name = 'Type of repair'
    elif choice == 2:
        repair_places = electronics_repair_places
        type_column_name = 'Type of electronics'
    else:
        return jsonify({'error': 'Invalid choice'}), 400

    repair_places[type_column_name] = repair_places[type_column_name].astype(str)
    repair_places['type_similarity'] = repair_places[type_column_name].apply(
        lambda x: fuzz.partial_ratio(user_type_of_repair, x) if isinstance(x, str) else 0
    )

    num_neighbors = 10
    knn = NearestNeighbors(n_neighbors=num_neighbors).fit(np.radians(repair_places[['latitude', 'longitude']].values))
    distance, indices = knn.kneighbors(np.radians([[latitude, longitude]]))
    nearest_neighbors_indices = indices.flatten()
    nearest_neighbors_data = repair_places.iloc[nearest_neighbors_indices].copy()

    nearest_neighbors_data['distance'] = nearest_neighbors_data.apply(
        lambda row: haversine((latitude, longitude), (row['latitude'], row['longitude'])),
        axis=1
    )

    # Remove rows with NaN or infinite distances
    nearest_neighbors_data = nearest_neighbors_data.dropna(subset=['distance'])
    nearest_neighbors_data = nearest_neighbors_data[np.isfinite(nearest_neighbors_data['distance'])]

    filtered_data = repair_places[repair_places[type_column_name] == user_type_of_repair].copy()
    combined_data = pd.concat([filtered_data, nearest_neighbors_data])
    combined_data = combined_data.sort_values(by=['type_similarity', 'distance'])

    logging.debug(f'Combined data for map: {combined_data}')

    map_center = [latitude, longitude]
    m = folium.Map(location=map_center, zoom_start=12)

    folium.Marker(
        location=(latitude, longitude),
        popup='User Location',
        icon=folium.Icon(color='red')
    ).add_to(m)

    for _, row in combined_data.iterrows():
        destination = (row['latitude'], row['longitude'])
        popup = f"{row['name']}<br>{row['address']}<br>Distance: {row['distance']:.2f} km<br>{type_column_name}: {row[type_column_name]}<br>Rating: {row['Rating ']:.2f}" if 'Rating ' in row else ""

        folium.Marker(location=(row['latitude'], row['longitude']), popup=popup).add_to(m)

    map_html = m._repr_html_()

    return render_template_string("""
        <!DOCTYPE html>
        <html>
        <head>
            <title>Repair Shops Map</title>
            <meta charset="utf-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            {{ folium_map | safe }}
        </head>
        <body>
        </body>
        </html>
    """, folium_map=map_html)

@app.route('/ping', methods=['GET'])
def ping():
    return "pong"

@app.route('/get_repair_types', methods=['POST'])
def get_repair_types():
    data = request.json
    category = data['category']

    if category == 'Car Repair':
        repair_places = car_repair_places
        type_column_name = 'Type of repair'
    elif category == 'Electronics Repair':
        repair_places = electronics_repair_places
        type_column_name = 'Type of electronics'
    else:
        return jsonify({'error': 'Invalid category'}), 400

    types_of_repairs = repair_places[type_column_name].dropna().unique().tolist()
    return jsonify({"types": types_of_repairs})

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0')
