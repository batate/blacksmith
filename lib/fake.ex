defmodule Blacksmith.Fake do
  @data %{
    user_name: ~w(Millows Linnot Harbal Barbence1991 Threangster1956 Cusible Youde1955 Beigues Sairing Coloutere Queed1986 Wasoned Whencer Sefuldsider Quushey40 Stiverrom1931 Musitch Feep1954 Arou1958 Theyeare Ciancer Hicustant Anou1967 Vents1938 Oweig1989 Exed1951 Youtrace Whentom Mearge65 Thenoth Cittle Comarrid Teemen Shoody31 Readdligning1943 Hisdon Moret1939 Beenarile Leord1936 Poncelf Herm1943 Plase1989 Paten1954 Luseple31 Wassaimmat Shink1959 Blaccurity Licut1962 Prioned),
    first_name: ~w(Ernest Robert Walter Graig Thomas Eunice Steve Barbara Douglas Amber Juanita Marion Angela Peggy Ernest Robert Debra Kenneth Joyce Eileen Alexander Juan Charles David Jayson Richard Stepanie Cheryl Joseph Emily Darrell Eddie Michael Kim Jose Michelle Walter Linda Earl Rosa Daniel Noel Raymond Alta Charles Bennie Terry Judy Eleanor),
    last_name: ~w(Lee Mares Cowles Rodriguez Hanna Hernandez Brown Kraemer Henry Romero Wellman Wakefield Carpenter Marshall Hammett Farley Huff Jolly Albanese Howes Wagner Kutcher Hayes Streicher Nelson Royster Campbell Vaughan Johnson Allen Curry Stutes Russo Shannon Herman Swanson Horowitz Houston Scruggs Griffin Hall Hutchinson Downey Blevins Smith Rogers Allen McLaughlin Contreras),
    email: ~w(ErnestBLee1@icmib.com RobertCMares1@icmib.com WalterNCowles1@icmib.com GraigARodriguez1@icmib.com ThomasTHanna1@icmib.com EuniceJHernandez1@icmib.com SteveDBrown1@icmib.com BarbaraSKraemer1@icmib.com DouglasQHenry1@icmib.com AmberDRomero1@icmib.com JuanitaCWellman1@icmib.com MarionRWakefield1@icmib.com AngelaCCarpenter1@icmib.com PeggyCMarshall1@icmib.com ErnestCHammett1@icmib.com RobertCFarley1@icmib.com DebraDHuff1@icmib.com KennethRJolly1@icmib.com JoyceSAlbanese1@icmib.com EileenCHowes1@icmib.com AlexanderJWagner1@icmib.com JuanMKutcher1@icmib.com CharlesDHayes1@icmib.com DavidIStreicher1@icmib.com JaysonVNelson1@icmib.com RichardWRoyster1@icmib.com StepanieJCampbell1@icmib.com CherylDVaughan1@icmib.com JosephBJohnson1@icmib.com EmilyJAllen1@icmib.com DarrellLCurry1@icmib.com EddieRStutes1@icmib.com MichaelJRusso1@icmib.com KimDShannon1@icmib.com JoseKHerman1@icmib.com MichelleASwanson1@icmib.com WalterSHorowitz1@icmib.com LindaMHouston1@icmib.com EarlDScruggs1@icmib.com RosaCGriffin1@icmib.com DanielLHall1@icmib.com NoelEHutchinson1@icmib.com RaymondIDowney1@icmib.com AltaGBlevins1@icmib.com CharlesESmith1@icmib.com BennieLRogers1@icmib.com TerryDAllen1@icmib.com JudyGMcLaughlin1@icmib.com EleanorHContreras1@icmib.com),
    word: ~w(office convention farm control gaming oral poultry office garment employment employee top nurse homeowner gate oral lobby concrete credit operations loan driver-sales bench photographic bureau line market sheet computer receive-and-deliver purchase-and-sales data account money it clerk account word hello what today music book sweet measurer building cardiographer scanner),
    sentence: [
      "What kind of bear is best? ",
      "That's a ridiculous question. ",
      "False. ",
      "Black bear. ",
      "That's debatable. ",
      "There are basically two schools of thought. ",
      "Bears eat beets. ",
      "Bears, beets, Battlestar Galactica. ",
      "What is going on?! ",
      "What are you doing?! ",
      "Guess what? ",
      "I have flaws. ",
      "What are they? ",
      "Oh I donno, I sing in the shower? ",
      "Sometimes I spend too much time volunteering. ",
      "Occasionally I will hit somebody with my car. ",
      "So sue me-- no, don't sue me. ",
      "That's opposite the point I am trying to make. "]
  }

  @unique [:user_name, :first_name, :last_name, :email]
  @not_unique [:word, :sentence]

  def start_link do
    Agent.start_link(fn ->
      seed = Application.get_env(:ex_unit, :seed)
      :random.seed(seed, seed, seed)

      Enum.reduce(@data, %{}, fn
        {k, _}, map when k in @not_unique -> map
        {:user_name, v}, map -> Map.put(map, :user_name, Enum.shuffle(pair(v)))
        {k, v}, map -> Map.put(map, k, Enum.shuffle(v))
      end)
    end, name: __MODULE__)
  end

  Enum.each(@unique, fn k ->
    def unquote(k)() do
      Agent.get_and_update(__MODULE__, fn data ->
        [hd|tl] = data[unquote(k)]
        {hd, Map.put(data, unquote(k), tl)}
      end)
    end
  end)

  Enum.each(@not_unique, fn k ->
    v = @data[k]
    def unquote(k)() do
      list = unquote(v)
      ix = :random.uniform(length(list) + 1) - 1
      Enum.at(list, ix)
    end
  end)

  def password do
    numbers       = 0..9         |> Enum.shuffle |> Enum.take(3) |> Enum.join
    lower_letters = ?a..?z       |> Enum.shuffle |> Enum.take(4) |> Enum.join
    upper_letters = ?A..?Z       |> Enum.shuffle |> Enum.take(3) |> Enum.join
    special       = '!@#\{$\%\}' |> Enum.shuffle |> Enum.take(1) |> Enum.join

    numbers <> lower_letters <> upper_letters <> special
  end

  defp pair(data) do
    for x <- data, y <- data do
      x <> y
    end
  end
end
