load("schema.star", "schema")
load("render.star", "render")
load("http.star", "http")
load("cache.star", "cache")
load("hash.star", "hash")

LOGO_URL = "https://i.postimg.cc/BvvwMqRr/pixil-frame-0-2.png?dl=1"

def image_data(url):
    cached = cache.get(url)
    if cached:
        return cached

    response = http.get(url)

    if response.status_code != 200:
        fail("Image not found", url)

    data = response.body()
    cache.set(url, data)

    return data

def main(config):
    TOKEN = config.get("token")
    if not TOKEN:
        fail("No token provided")

    response = http.get("https://data.parcelapp.net/data.php?caller=yes&compression=yes&version=4", headers={"Cookie": "account_token=%s" % TOKEN})

    if response.status_code != 200:
        fail("No parcels found", response)

    parcels = response.json()[0]
    active_parcels = [parcel for parcel in parcels if parcel[3] == "yes"]

    logo = render.Padding(
      pad=(0,0,2,0),
      child=render.Image(src=image_data(LOGO_URL), width=13, height=13)
    )

    if not active_parcels:
      return []

    last_parcel = active_parcels[0]
    number = last_parcel[0]
    name = last_parcel[1]
    provider = last_parcel[2]
    last_status = last_parcel[4][0]
    status_text = last_status[0]
    status_date = last_status[1]

    return render.Root(
        child=render.Column(
          expanded=True,
          main_align="space_between",
          children=[
            render.Row(
              children=[
                logo,
                render.Marquee(
                  width=64-13-2,
                  child=render.Text(name, font="6x13")
                ),
              ]
            ),
            render.Marquee(
              width=64,
              child=render.Text(status_text),
            ),
            render.Text(status_date, font="CG-pixel-3x5-mono")
          ]
        )
    )

def get_schema():
    return schema.Schema(
        version = "1",
        fields = [
            schema.Text(
                id = "token",
                name = "ParcelApp Web Token",
                desc = "`account_token` cookie from https://web.parcelapp.net/",
                icon = "key",
            ),
        ],
    )
