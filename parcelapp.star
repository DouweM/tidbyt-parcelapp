load("schema.star", "schema")
load("render.star", "render")
load("http.star", "http")
load("time.star", "time")
load("humanize.star", "humanize")
load("pixlib/const.star", "const")
load("pixlib/file.star", "file")
load("pixlib/html.star", "html")

API_URL = "https://data.parcelapp.net/data.php?caller=yes&compression=yes&version=4"

def main(config):
    TOKEN = config.get("token")
    if not TOKEN:
        return render.Root(
            child=render.Box(
                child=render.WrappedText("ParcelApp Web Token not configured")
            )
        )

    response = http.get(API_URL, headers={"Cookie": "account_token=%s" % TOKEN})

    if response.status_code != 200:
        fail("No parcels found: ", response)

    response_body = response.body()
    if not response_body.startswith("["):
      error_message = response_body.strip()
      if error_message == 'VERIFICATIONFAILURE':
        fail("Invalid ParcelApp Web Token")
      else:
        fail("Invalid response: ", error_message)

    parcels = response.json()[0]
    active_parcels = sorted(
      [parcel for parcel in parcels if parcel[3] == "yes"],
      key=lambda parcel: [
        0 if parcel[5] else 1, # Parcels with delivery date first
        time.parse_time(parcel[5], "2006-01-02 15:04:00") if parcel[5] else None
      ]
    )

    logo = render.Padding(
      pad=(0,0,2,0),
      child=render.Image(src=file.read('icon.png'), width=13, height=13)
    )

    if not active_parcels:
      return []

    last_parcel = active_parcels[0]
    number = last_parcel[0]
    name = html.unescape(last_parcel[1])
    provider = last_parcel[2]

    last_status = last_parcel[4][0]
    status_text = html.unescape(last_status[0])
    status_date = html.unescape(last_status[1])
    status_location = html.unescape(last_status[3])

    delivery_date = last_parcel[5]

    if delivery_date:
      timestamp = time.parse_time(delivery_date, "2006-01-02 15:04:00")
      detail_text = "ETA: " + humanize.time_format("EEEE", timestamp) # TODO: Date if further out than 1 week
    elif status_location:
      detail_text = status_location
    else:
      detail_text = status_date

    return render.Root(
        child=render.Column(
          expanded=True,
          main_align="space_between",
          children=[
            render.Row(
              children=[
                logo,
                render.Marquee(
                  width=const.WIDTH-13-2,
                  child=render.Text(name, font="6x13")
                ),
              ]
            ),
            render.Marquee(
              width=const.WIDTH,
              child=render.Text(status_text),
            ),
            render.Marquee(
              width=const.WIDTH,
              child=render.Text(detail_text, font="CG-pixel-3x5-mono")
            )
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
