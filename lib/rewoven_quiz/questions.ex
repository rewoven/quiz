defmodule RewovenQuiz.Questions do
  @moduledoc "144 sustainability quiz questions across 6 categories."

  defstruct [:id, :question, :options, :correct, :explanation, :difficulty, :category]

  @type t :: %__MODULE__{
    id: String.t(),
    question: String.t(),
    options: [String.t()],
    correct: non_neg_integer(),
    explanation: String.t(),
    difficulty: :easy | :medium | :hard,
    category: String.t()
  }

  def all, do: questions()

  def by_category(cat), do: Enum.filter(questions(), &(&1.category == cat))

  def categories, do: Enum.map(questions(), & &1.category) |> Enum.uniq()

  def pick(count, category \\ "all") do
    pool = if category == "all", do: questions(), else: by_category(category)
    pool |> Enum.shuffle() |> Enum.take(count)
  end

  defp q(id, question, options, correct, explanation, difficulty, category) do
    %__MODULE__{
      id: id, question: question, options: options,
      correct: correct, explanation: explanation,
      difficulty: difficulty, category: category
    }
  end

  defp questions do
    [
      # ── FAST FASHION ──
      q("ff1","What does \"fast fashion\" mean?",["Clothing made slowly and carefully","Cheap clothes made quickly to follow trends","Handmade luxury clothing","Clothing designed to last 10+ years"],1,"Fast fashion = fast production, low quality, disposable trends.",:easy,"Fast Fashion"),
      q("ff2","Which material is most commonly used in fast fashion?",["Polyester","Silk","Linen","Wool"],0,"Polyester is cheap and easy to mass-produce.",:easy,"Fast Fashion"),
      q("ff3","True or False: Fast fashion is designed to be long-lasting.",["True","False"],1,"It's intentionally low-quality so people buy more often.",:easy,"Fast Fashion"),
      q("ff4","What is \"overconsumption\"?",["Wearing the same clothes too often","Buying more clothes than you need","Donating too many clothes","Only buying second-hand"],1,"Overconsumption = unnecessary purchasing → more waste.",:easy,"Fast Fashion"),
      q("ff5","Which option is more sustainable?",["Buying 3 cheap shirts","Buying 1 high-quality shirt","Buying clothes every week","Throwing clothes away after one use"],1,"Durable clothing reduces replacement frequency and waste.",:easy,"Fast Fashion"),
      q("ff6","What is a \"microtrend\"?",["A long-lasting fashion movement","A trend that lasts only a few days or weeks","A trend created by luxury brands","A trend based on fabric thickness"],1,"Microtrends burn out fast → more waste.",:easy,"Fast Fashion"),
      q("ff7","Which of these is a sign of fast fashion?",["High transparency reports","Weekly new collections","Long-lasting durable fabrics","Repair services"],1,"Constant new drops encourage constant buying.",:easy,"Fast Fashion"),
      q("ff8","What is the \"real cost\" of a cheap shirt?",["Only the money you pay","Money + environmental + social impact","Only shipping costs","None"],1,"The price tag hides pollution and worker exploitation.",:easy,"Fast Fashion"),
      q("ff9","What is the main driver of fast fashion pollution?",["High prices","Slow production","High-volume manufacturing","Limited clothing drops"],2,"Fast fashion produces too much, too fast.",:medium,"Fast Fashion"),
      q("ff10","What makes polyester harmful?",["It is fully biodegradable","It sheds microplastics","It is made from plants","It lasts for only one wash"],1,"Polyester = plastic → microplastics in water.",:medium,"Fast Fashion"),
      q("ff11","True or False: Cotton always has a lower environmental impact than polyester.",["True","False"],1,"Cotton can be better, but not always. It depends on method used.",:medium,"Fast Fashion"),
      q("ff12","What is \"greenwashing\"?",["A new eco-friendly washing technique","Misleading sustainability marketing","Washing clothes using recycled water","A method for dye removal"],1,"Brands pretend to be sustainable without proof.",:medium,"Fast Fashion"),
      q("ff13","Which fabric has the lowest water footprint?",["Cotton","Linen","Wool","Nylon"],1,"Linen (flax) uses far less water.",:medium,"Fast Fashion"),
      q("ff14","Why do fast fashion prices stay low?",["Brands use expensive materials","Very efficient, ethical labour","Cheap labour + cheap materials","Limited production"],2,"Low cost = low wages + low-quality fibre.",:medium,"Fast Fashion"),
      q("ff15","Which action reduces fashion waste the most?",["Buying more clothes","Buying fewer, higher-quality clothes","Following microtrends","Wearing clothes once"],1,"Longevity = fewer garments produced.",:medium,"Fast Fashion"),
      q("ff16","What is the biggest issue with rapid fashion cycles?",["They increase creativity","They reduce demand","They encourage disposable buying","They make clothes more durable"],2,"Fast cycles → constant buying → waste.",:medium,"Fast Fashion"),
      q("ff17","Rank fabrics from worst → best environmental impact.",["Linen → Wool → Polyester","Polyester → Cotton → Linen","Cotton → Polyester → Linen","Wool → Polyester → Cotton"],1,"Polyester → Cotton → Linen.",:hard,"Fast Fashion"),
      q("ff18","Why don't clothing prices reflect environmental impact?",["Because pollution is measured incorrectly","Externalities aren't included in price","Because brands want to overcharge","Because fashion has no impact"],1,"Pollution isn't priced → artificially cheap clothes.",:hard,"Fast Fashion"),
      q("ff19","What is \"planned obsolescence\" in fashion?",["Designing clothes that last decades","Designing clothes that break or become unfashionable quickly","Designing for repairs","Designing clothing for upcycling"],1,"Brands make products intentionally short-lived.",:hard,"Fast Fashion"),
      q("ff20","Why is organic cotton not always more sustainable?",["It uses more chemicals","It uses land and water differently","It cannot be dyed","It lasts fewer washes"],1,"Organic doesn't mean low water-use or efficient farming.",:hard,"Fast Fashion"),
      q("ff21","What policy would reduce fashion waste most effectively?",["More trend cycles","Banning second-hand clothing","Taxing high-waste production","Increasing billboard ads"],2,"Pricing externalities reduces overproduction.",:hard,"Fast Fashion"),
      q("ff22","What is \"cost per wear\"?",["Price divided by number of wears","Total price multiplied by ownership time","Price divided by brand name","Cost of repairing clothes"],0,"Lower cost-per-wear = more sustainable value.",:hard,"Fast Fashion"),
      q("ff23","Why is relying on recycled polyester limited?",["It cannot be recycled again","It is too expensive","It releases no microplastics","It is naturally biodegradable"],0,"Most recycled polyester becomes non-recyclable → dead-end.",:hard,"Fast Fashion"),
      q("ff24","Which factor increases sustainability the most?",["More trend cycles","Higher purchasing frequency","Longer product lifespans","More polyester production"],2,"Longevity reduces overall consumption + waste.",:hard,"Fast Fashion"),

      # ── CIRCULAR ECONOMY ──
      q("ce1","What is a circular economy?",["An economy based on throwing items away","An economy where materials are reused, repaired, and recycled","An economy that only uses new materials","A system focused on fast production"],1,"A circular economy keeps materials in use as long as possible.",:easy,"Circular Economy"),
      q("ce2","Which diagram represents a linear economy?",["Make → Use → Return","Take → Make → Waste","Repair → Reuse → Recycle","Collect → Process → Reuse"],1,"A linear economy follows a one-way flow that ends in waste.",:easy,"Circular Economy"),
      q("ce3","True or False: Repairing an item is part of the circular economy.",["True","False"],0,"Repair extends a product's life and reduces waste.",:easy,"Circular Economy"),
      q("ce4","What does \"reuse\" mean?",["Throwing something away","Using a product again instead of buying new","Burning waste for energy","Replacing a broken item instantly"],1,"Reuse keeps items circulating longer.",:easy,"Circular Economy"),
      q("ce5","What is upcycling?",["Turning old materials into higher-value products","Burning materials","Recycling plastic into plastic","Throwing clothes away"],0,"Upcycling transforms waste into something of higher value.",:easy,"Circular Economy"),
      q("ce6","What does \"closing the loop\" mean?",["Ending recycling","Creating waste faster","Keeping materials in use instead of throwing them away","Stopping production permanently"],2,"Resources continuously circulate.",:easy,"Circular Economy"),
      q("ce7","Which example fits a circular model?",["Buying new clothes weekly","Repairing a broken bag","Throwing out old items","Ignoring waste"],1,"Repairing prevents unnecessary new consumption.",:easy,"Circular Economy"),
      q("ce8","Why is extending a product's life good for the environment?",["It increases waste","It reduces production and resource use","It requires more material","It raises prices"],1,"The longer an item lasts, the fewer new materials are needed.",:easy,"Circular Economy"),
      q("ce9","Why is the linear economy unsustainable?",["It reuses materials","It depends on infinite resources","It reduces waste naturally","It avoids pollution"],1,"Linear systems rely on constant extraction from limited resources.",:medium,"Circular Economy"),
      q("ce10","What is \"resource efficiency\"?",["Using as many materials as possible","Using materials in the smartest, most sustainable way","Throwing products away at the end of life","Over-consuming resources"],1,"Efficient resource use reduces waste and environmental impact.",:medium,"Circular Economy"),
      q("ce11","True or False: Recycling is the only part of circularity.",["True","False"],1,"Circularity also includes reuse, repair, remanufacturing, and upcycling.",:medium,"Circular Economy"),
      q("ce12","Which company action reflects circular design?",["Designing clothes meant to be thrown away","Using materials that can be repaired and recycled","Selling products with no repair options","Changing trends weekly"],1,"Circular design focuses on durability.",:medium,"Circular Economy"),
      q("ce13","Which product is most likely to fit into a circular model?",["A phone with glued-in batteries","A jacket with repairable zippers and modular parts","A shirt designed for one-time use","A plastic bag"],1,"Modular and repairable items stay in use longer.",:medium,"Circular Economy"),
      q("ce14","How does upcycling reduce carbon emissions?",["By increasing production","By reducing the need for new materials","By burning old products","By shortening product lifespan"],1,"Using existing materials avoids emissions from making new ones.",:medium,"Circular Economy"),
      q("ce15","What is \"remanufacturing\"?",["Throwing away a product","Making a new item using old parts","Ignoring damaged materials","Always recycling first"],1,"Remanufacturing gives parts a second life.",:medium,"Circular Economy"),
      q("ce16","Which strategy creates the least waste?",["Reuse","Recycling","Repair","Burning waste"],2,"Repair keeps products functional the longest.",:medium,"Circular Economy"),
      q("ce17","How does circularity help fight climate change?",["It increases consumption","It reduces extraction and production emissions","It causes more pollution","It promotes fast fashion"],1,"Using fewer virgin materials lowers energy use and emissions.",:hard,"Circular Economy"),
      q("ce18","Which industry benefits most from circular innovation?",["Nuclear energy","Textile and fashion","Luxury jewellery","Airline catering"],1,"Textiles have massive waste and resource demands.",:hard,"Circular Economy"),
      q("ce19","Which is the most effective circular strategy?",["Recycling","Reuse","Repair","Refuse"],3,"Refusing unnecessary items eliminates waste at the source.",:hard,"Circular Economy"),
      q("ce20","What makes a product \"circular by design\"?",["It is trendy","It's made to be repaired, reused, or recycled","It looks eco-friendly","It is cheap"],1,"Built for multiple lifecycles.",:hard,"Circular Economy"),
      q("ce21","True or False: Recycling is the highest-impact circular solution.",["True","False"],1,"Less impactful than reducing, reusing, or repairing.",:hard,"Circular Economy"),
      q("ce22","Identify a major flaw in current circular systems.",["Too much reuse","Lack of repair skills and infrastructure","Too many recycling options","Overproduction of circular products"],1,"Most people can't repair items.",:hard,"Circular Economy"),
      q("ce23","What is the difference between cradle-to-grave and cradle-to-cradle?",["Same concept","Cradle-to-grave ends in waste; cradle-to-cradle recycles into new products","Cradle-to-grave recycles; cradle-to-cradle ends in waste","Both ignore recycling"],1,"Cradle-to-cradle is circular; cradle-to-grave is linear.",:hard,"Circular Economy"),
      q("ce24","A brand claims its product is circular but offers no repair options. What's the issue?",["It's too sustainable","It's greenwashing","It's too expensive","It's over-designed"],1,"Circular claims must match real features.",:hard,"Circular Economy"),

      # ── TEXTILE LIFECYCLE ──
      q("tl1","Which is the correct order of a textile lifecycle?",["Use → Throw away → Production","Raw fibre → Fabric → Clothing → Use → Disposal","Disposal → Fabric → Raw fibre","Clothing → Fabric → Fibre"],1,"Starts as raw fibre, becomes fabric, then clothing, used, then disposed.",:easy,"Textile Lifecycle"),
      q("tl2","What stage of a textile's life uses the most water?",["Spinning","Dyeing","Transport","Packaging"],1,"Dyeing and finishing use huge amounts of water.",:easy,"Textile Lifecycle"),
      q("tl3","True or False: Dyeing is a major source of water pollution.",["True","False"],0,"Toxic dyes often enter rivers untreated.",:easy,"Textile Lifecycle"),
      q("tl4","What happens to most discarded clothes globally?",["They are recycled","They are stored forever","They end up in landfill or are burned","They turn into compost"],2,"Most textile waste is landfilled or incinerated.",:easy,"Textile Lifecycle"),
      q("tl5","What is pre-consumer textile waste?",["Clothes thrown away after wearing","Factory scraps and offcuts","Donated clothing","Old clothes sold second-hand"],1,"Created before the product reaches customers.",:easy,"Textile Lifecycle"),
      q("tl6","What is post-consumer textile waste?",["Scraps from textile factories","Unused fibres","Clothes discarded after use","Fabric rolls in storage"],2,"Clothing thrown away after wearing.",:easy,"Textile Lifecycle"),
      q("tl7","What part of the textile journey often involves pesticides?",["Spinning","Growing cotton","Sewing","Recycling"],1,"Conventional cotton requires pesticides.",:easy,"Textile Lifecycle"),
      q("tl8","True or False: Polyester sheds microplastics when washed.",["True","False"],0,"Synthetic fibres break into microplastics during washing.",:easy,"Textile Lifecycle"),
      q("tl9","Which stage creates the most carbon emissions?",["Sewing","Raw material production","Packaging","Retail"],1,"Fibre production has the highest carbon footprint.",:medium,"Textile Lifecycle"),
      q("tl10","Why are polyester clothes hard to recycle?",["They melt too quickly","They are often blended with other fibres","They are too soft","They are too expensive"],1,"Blended fabrics make separation difficult.",:medium,"Textile Lifecycle"),
      q("tl11","True or False: Blended fabrics are easier to reuse.",["True","False"],1,"Blends are harder to recycle due to mixed content.",:medium,"Textile Lifecycle"),
      q("tl12","What is a key environmental issue in the dyeing stage?",["Fabric shrinkage","Wastewater pollution","Labour shortages","Slow production"],1,"Dyeing creates toxic wastewater.",:medium,"Textile Lifecycle"),
      q("tl13","What is a textile's \"end-of-life\" stage?",["When it enters production","When it is sold","When it is discarded by the consumer","When cotton is harvested"],2,"Disposal after use.",:medium,"Textile Lifecycle"),
      q("tl14","Why do clothes shed microplastics?",["They contain natural fibres","Synthetic fibres break apart during friction","They are washed too often","They are recycled incorrectly"],1,"Polyester and nylon release microplastics when stressed.",:medium,"Textile Lifecycle"),
      q("tl15","Which stage is most labour-intensive?",["Raw material extraction","Sewing and garment construction","Disposal","Recycling"],1,"Cutting, sewing, and assembly rely on manual labour.",:medium,"Textile Lifecycle"),
      q("tl16","Which stage contributes most to chemical pollution?",["Spinning","Dyeing & finishing","Retail","Transport"],1,"Dyeing uses chemicals that can leak into ecosystems.",:medium,"Textile Lifecycle"),
      q("tl17","Why is textile recycling often inefficient?",["Fabrics are too clean","Fibres are hard to separate, especially blends","No demand for recycled materials","It requires too much land"],1,"Mixed fibres make automated sorting extremely difficult.",:hard,"Textile Lifecycle"),
      q("tl18","Which fibre has the lowest environmental impact across its lifecycle?",["Conventional cotton","Polyester","Linen (flax)","Nylon"],2,"Linen uses less water and chemicals.",:hard,"Textile Lifecycle"),
      q("tl19","True or False: Mechanical recycling shortens fibre length.",["True","False"],0,"Shredding breaks fibres, reducing quality.",:hard,"Textile Lifecycle"),
      q("tl20","What is a major barrier to large-scale textile recycling?",["Too many recycling plants","Lack of sorting technology","Overproduction of linen","Low clothing demand"],1,"Sorting blends and colours is complex and expensive.",:hard,"Textile Lifecycle"),
      q("tl21","Which stage has the largest hidden environmental footprint?",["Retail","Transport","Consumer use (washing, drying)","Sewing"],2,"Frequent washing, drying, and ironing use huge energy.",:hard,"Textile Lifecycle"),
      q("tl22","What makes chemical recycling different from mechanical?",["It dyes fibres","It dissolves fibres and rebuilds them as new","It cuts fibres into yarn","It burns waste"],1,"Chemical recycling breaks fibres down molecularly.",:hard,"Textile Lifecycle"),
      q("tl23","Why do darker dyed fabrics have higher environmental impact?",["They are more expensive","They require more dye and chemicals","They dry slower","They sell less"],1,"Deep colours need more dye.",:hard,"Textile Lifecycle"),
      q("tl24","What is the main issue with fast fashion lifecycle speed?",["Clothes last too long","Clothes become waste too quickly","Recycling rates are too high","Clothes never get worn"],1,"Speeds up production → disposal.",:hard,"Textile Lifecycle"),

      # ── SUSTAINABLE BRANDS ──
      q("sb1","What makes a brand \"sustainable\"?",["Selling trendy clothes","Using materials and practices that reduce environmental harm","Releasing new collections every week","Only selling expensive items"],1,"Reduced environmental impact + ethical practices.",:easy,"Sustainable Brands"),
      q("sb2","True or False: An eco-label always means a brand is sustainable.",["True","False"],1,"Some labels can be misleading or unverified.",:easy,"Sustainable Brands"),
      q("sb3","Which is a legitimate sustainability certification?",["UltraGreen+","GOTS","FashionStar Label","EcoXPress"],1,"GOTS is a globally trusted organic textile certification.",:easy,"Sustainable Brands"),
      q("sb4","What is \"greenwashing\"?",["Washing clothes with eco-friendly soap","Making products green","Misleading consumers with fake sustainability claims","Dyeing clothes green"],2,"False or exaggerated eco-claims.",:easy,"Sustainable Brands"),
      q("sb5","What does \"ethical sourcing\" mean?",["All materials come from expensive suppliers","Workers are paid fairly and materials are responsibly produced","Products are sourced from influencers","Items are sourced as fast as possible"],1,"Protects workers and the environment.",:easy,"Sustainable Brands"),
      q("sb6","Which brand behaviour is most likely sustainable?",["No info about supply chain","Extremely low prices","Publishing detailed sustainability reports","Releasing 50 collections per year"],2,"Transparency is key.",:easy,"Sustainable Brands"),
      q("sb7","Why do some sustainable brands cost more?",["They want higher profits","They use higher-quality materials and pay fair wages","They avoid competition","They produce small sizes only"],1,"Ethical labour + sustainable materials raise costs.",:easy,"Sustainable Brands"),
      q("sb8","A brand advertises \"eco-friendly\" but provides no proof. What is this?",["Good marketing","Product innovation","Greenwashing","A new business model"],2,"Unverified claims = greenwashing.",:easy,"Sustainable Brands"),
      q("sb9","What does \"supply chain transparency\" mean?",["Hiding production details","Showing where materials come from and how products are made","Revealing marketing plans","Shortening shipping times"],1,"Helps consumers verify sustainability.",:medium,"Sustainable Brands"),
      q("sb10","Why might a brand track its carbon footprint?",["To raise prices","To understand and reduce its environmental impact","To impress customers only","To calculate shipping delays"],1,"Measuring helps identify reduction opportunities.",:medium,"Sustainable Brands"),
      q("sb11","True or False: A brand can be sustainable if it uses plastic sometimes.",["True","False"],0,"Sustainability depends on total impact.",:medium,"Sustainable Brands"),
      q("sb12","Which is a sign a sustainability claim may be false?",["Detailed data","Independent verification","Vague phrases like \"100% eco-friendly\"","Transparency reports"],2,"Vague buzzwords are red flags.",:medium,"Sustainable Brands"),
      q("sb13","What is \"circular fashion retail\"?",["Selling circular-shaped clothing","Reselling, repairing, and renting clothing","Selling clothes in a circle","Only selling sustainable colours"],1,"Extends clothing lifespan.",:medium,"Sustainable Brands"),
      q("sb14","What is the purpose of sustainability reporting?",["List celebrity collaborations","Brag about profits","Show impact metrics and accountability","Hide supply chain issues"],2,"Shows progress and areas for improvement.",:medium,"Sustainable Brands"),
      q("sb15","Which metric matters most for judging sustainability?",["Number of Instagram followers","How often they release trends","Carbon footprint, water use, labour conditions","Colour of the logo"],2,"Measurable environmental + social impact.",:medium,"Sustainable Brands"),
      q("sb16","Why is traceability important?",["It helps track a product from source to consumer","It reduces brand popularity","It increases advertising","It makes trends last longer"],0,"Ensures materials and labour meet ethical standards.",:medium,"Sustainable Brands"),
      q("sb17","A brand claims \"100% sustainable\" with no data. What does this indicate?",["Complete honesty","Likely greenwashing","A new marketing style","High durability"],1,"Absolute claims with no evidence are misleading.",:hard,"Sustainable Brands"),
      q("sb18","What is the difference between ESG and sustainability?",["ESG focuses on financial markets; sustainability on environmental & social impact","They are the same","ESG only deals with energy","Sustainability only deals with profits"],0,"ESG is for investors; sustainability is real-world impact.",:hard,"Sustainable Brands"),
      q("sb19","What makes a sustainability strategy \"scalable\"?",["It works only in small shops","It can expand across supply chains and locations","It is extremely expensive","It only applies to luxury brands"],1,"Scalability = ability to expand impact.",:hard,"Sustainable Brands"),
      q("sb20","A brand claims recycled polyester. What's important to check?",["Whether colours are trendy","Whether the recycled material is traceable and reduces impact","Whether influencers promote it","Whether packaging is good"],1,"Claims must be verified.",:hard,"Sustainable Brands"),
      q("sb21","True or False: Offsetting emissions alone makes a brand sustainable.",["True","False"],1,"Offsetting doesn't replace real reductions.",:hard,"Sustainable Brands"),
      q("sb22","A brand says \"sustainably sourced\" but investigations show worker abuse. What is this?",["High efficiency","Greenwashing","Successful sustainability","Carbon neutrality"],1,"Sustainability includes labour rights.",:hard,"Sustainable Brands"),
      q("sb23","Which approach gives the most accurate sustainability evaluation?",["Marketing slogans","Third-party certifications + detailed impact data","Influencer partnerships","Fast trend cycles"],1,"Independent verification prevents misleading claims.",:hard,"Sustainable Brands"),
      q("sb24","A company uses recycled materials but overproduces. What's the issue?",["Recycled materials are harmful","Overproduction still causes massive waste","Recycled fibres never work","Clothes are too durable"],1,"Must reduce volume, not just change materials.",:hard,"Sustainable Brands"),

      # ── RECYCLING ──
      q("rc1","What is recycling?",["Throwing items away","Turning waste materials into new materials","Burning waste for energy","Washing items with water"],1,"Transforms used materials for reuse.",:easy,"Recycling"),
      q("rc2","True or False: All fabrics can be recycled easily.",["True","False"],1,"Many fabrics, especially blends, are difficult to recycle.",:easy,"Recycling"),
      q("rc3","Why are blended fabrics hard to recycle?",["They are too colourful","The fibres are mixed and hard to separate","They smell too much","They are too soft"],1,"Separating fibres is technically challenging.",:easy,"Recycling"),
      q("rc4","What is \"downcycling\"?",["Turning materials into higher-value products","Turning materials into lower-value products","Burning textiles","Reusing clothes"],1,"Reduces material quality.",:easy,"Recycling"),
      q("rc5","What is contamination in recycling?",["When waste is clean","When recycling bins are mixed with non-recyclables","When recycling is too efficient","When items are washed"],1,"Makes recycling less effective.",:easy,"Recycling"),
      q("rc6","True or False: Colour affects how easy it is to recycle textiles.",["True","False"],0,"Dark or mixed colours need more chemicals.",:easy,"Recycling"),
      q("rc7","What is closed-loop recycling?",["Reusing materials until they degrade","Recycling a material back into the same type of product","Burning materials for heat","Shredding materials into dust"],1,"Creates new versions of the original product.",:easy,"Recycling"),
      q("rc8","Which is most commonly recycled in textiles?",["Pure polyester","Polyester–cotton blends","Wool–nylon blends","Leather"],0,"Pure polyester is easier to process.",:easy,"Recycling"),
      q("rc9","Which textile is easiest to mechanically recycle?",["100% cotton","Cotton-polyester blend","Spandex","Leather"],0,"Pure fibres recycle more smoothly.",:medium,"Recycling"),
      q("rc10","Why does polyester need heat during recycling?",["To dye it","To melt and reshape it","To wash it","To make it softer"],1,"Polyester is a plastic that must be melted.",:medium,"Recycling"),
      q("rc11","True or False: Cotton can be mechanically recycled.",["True","False"],0,"Cotton can be shredded into shorter fibres.",:medium,"Recycling"),
      q("rc12","Which items should be donated rather than recycled?",["Torn clothing","New or lightly used clothing","Wet clothing","Contaminated fabric"],1,"High-quality items should be reused.",:medium,"Recycling"),
      q("rc13","Why do many recycling markets collapse?",["Too few centres","No demand for recycled materials","Recycled products are too durable","Consumers recycle too much"],1,"Recycling only works when buyers need the output.",:medium,"Recycling"),
      q("rc14","What is a major difference between mechanical and chemical recycling?",["Chemical recycling breaks fibres into basic molecules","Mechanical recycling dyes fabrics","Chemical recycling is always eco-friendly","Mechanical recycling strengthens fibres"],0,"Chemical recycling molecularly rebuilds fibres.",:medium,"Recycling"),
      q("rc15","Which is more energy-efficient?",["Producing new polyester","Recycling polyester","Burning polyester","Mining polyester"],1,"Recycling requires less energy.",:medium,"Recycling"),
      q("rc16","What is the biggest issue in textile recycling facilities?",["Too many workers","Sorting materials correctly","Too few clothes","Too much technology"],1,"Sorting by fibre, colour, quality is extremely difficult.",:medium,"Recycling"),
      q("rc17","Why is textile recycling not widely scaled?",["Consumers don't buy enough","Sorting technology is expensive and not advanced enough","Takes too little time","Too profitable"],1,"Sorting blends and colours is costly.",:hard,"Recycling"),
      q("rc18","Which recycling method results in the highest-quality output?",["Mechanical recycling","Chemical recycling","Downcycling","Burning textiles"],1,"Chemical recycling can rebuild to near-virgin quality.",:hard,"Recycling"),
      q("rc19","True or False: Chemical recycling is always environmentally friendly.",["True","False"],1,"It can require heavy chemicals and high energy.",:hard,"Recycling"),
      q("rc20","Which textile is the biggest barrier to large-scale recycling?",["100% cotton","Wool","Cotton–polyester blends","Linen"],2,"Blends are extremely hard to separate.",:hard,"Recycling"),
      q("rc21","Why does recycling alone not solve fashion waste?",["Too fast","It doesn't reduce overproduction","Recycled clothes are too strong","People dislike recycled materials"],1,"Doesn't fix the root issue: producing too much.",:hard,"Recycling"),
      q("rc22","What determines how effective textile recycling is?",["Fabric colour only","Fibre purity, contamination, and sorting accuracy","Brand popularity","Garment size"],1,"Pure fibres recycle best.",:hard,"Recycling"),
      q("rc23","Which factor most limits fibre recovery rates?",["Number of trends","Damage to fibres during mechanical recycling","Popularity of thrifting","Fabric colour"],1,"Mechanical recycling shortens fibres.",:hard,"Recycling"),
      q("rc24","What is the biggest weakness of downcycling long-term?",["Too expensive","Materials eventually become unusable and still end up as waste","Creates too much profit","Makes fibres too strong"],1,"Downcycling delays waste but doesn't close the loop.",:hard,"Recycling"),

      # ── SUSTAINABLE LIFESTYLE ──
      q("sl1","What does \"living sustainably\" mean?",["Buying as many products as possible","Making choices that reduce environmental impact","Only purchasing luxury items","Living without electricity"],1,"About reducing harm to the planet.",:easy,"Sustainable Lifestyle"),
      q("sl2","True or False: Washing clothes less often can reduce environmental impact.",["True","False"],0,"Laundry uses water, energy, and sheds microplastics.",:easy,"Sustainable Lifestyle"),
      q("sl3","What is a simple way to reduce microplastic pollution?",["Washing at high temperatures","Washing synthetic clothes less often","Buying only dark clothes","Throwing clothes away quicker"],1,"Less washing = fewer microplastics.",:easy,"Sustainable Lifestyle"),
      q("sl4","What is mindful consumption?",["Buying without thinking","Buying only what you truly need","Buying anything on sale","Shopping every weekend"],1,"Intentional, reduced consumption.",:easy,"Sustainable Lifestyle"),
      q("sl5","Which of these habits is sustainable?",["Air-drying clothes","Using the dryer for every load","Buying new clothes weekly","Throwing away repairable items"],0,"Air-drying cuts energy use significantly.",:easy,"Sustainable Lifestyle"),
      q("sl6","Why is repairing clothes better than replacing?",["It is always cheaper","It reduces waste and avoids new production","It makes clothes look brand new","It increases fashion trends"],1,"Extends garment life and avoids new emissions.",:easy,"Sustainable Lifestyle"),
      q("sl7","True or False: Individual actions make no difference.",["True","False"],1,"Small actions add up, especially at scale.",:easy,"Sustainable Lifestyle"),
      q("sl8","What is a carbon footprint?",["A shoe print","Total greenhouse gases a person or activity produces","A type of recycled fabric","A clothing style"],1,"Measures climate impact from daily choices.",:easy,"Sustainable Lifestyle"),
      q("sl9","How can you lower your clothing-related carbon footprint?",["Buy frequently","Wash clothes in cold water","Throw clothes out after one use","Wash everything at 90°C"],1,"Cold washing reduces energy use dramatically.",:medium,"Sustainable Lifestyle"),
      q("sl10","Which pattern of shopping is most sustainable?",["Buying fewer, high-quality clothes","Buying fast fashion weekly","Buying based on trends only","Buying only discounted items"],0,"Durability reduces overconsumption.",:medium,"Sustainable Lifestyle"),
      q("sl11","True or False: Air drying is more sustainable than using a dryer.",["True","False"],0,"Dryers use lots of electricity.",:medium,"Sustainable Lifestyle"),
      q("sl12","What is one way to reduce waste at home?",["Using disposable items","Choosing reusable products","Buying unnecessary items","Using plastic bags frequently"],1,"Reusable items cut waste significantly.",:medium,"Sustainable Lifestyle"),
      q("sl13","What daily habit reduces water use?",["Washing clothes after every wear","Taking shorter showers","Leaving the tap running","Washing synthetic clothes daily"],1,"Shorter showers save water instantly.",:medium,"Sustainable Lifestyle"),
      q("sl14","What is the problem with \"eco-friendly\" trends?",["They last forever","They often encourage buying more","They save too much energy","They reduce brand profits"],1,"Overconsumption is still harmful even if \"eco\".",:medium,"Sustainable Lifestyle"),
      q("sl15","Which choice is better for the environment?",["Throwing away old clothes","Donating or reselling clothes","Buying duplicates","Buying only synthetic fabrics"],1,"Reuse extends garment life.",:medium,"Sustainable Lifestyle"),
      q("sl16","Why do sustainable habits matter long-term?",["They save time","They compound — small habits create large impact","They eliminate all emissions instantly","They make clothes last forever"],1,"Consistent habits add up.",:medium,"Sustainable Lifestyle"),
      q("sl17","Which lifestyle change has the highest environmental impact?",["Buying new clothes monthly","Reducing overall consumption","Washing synthetic clothes more often","Air-drying only"],1,"Reducing consumption cuts emissions and waste.",:hard,"Sustainable Lifestyle"),
      q("sl18","Why is \"buying eco-friendly items\" not always sustainable?",["Eco-items don't work","It still encourages consumption","They are illegal","They last too long"],1,"The most sustainable item is the one you don't buy.",:hard,"Sustainable Lifestyle"),
      q("sl19","True or False: Microplastic pollution only comes from oceans.",["True","False"],1,"Most comes from washing clothes and daily activities.",:hard,"Sustainable Lifestyle"),
      q("sl20","What is a realistic long-term sustainable goal?",["Never buying clothes again","Slowly shifting to durable, repairable items","Throwing away everything synthetic","Buying only luxury brands"],1,"Sustainable transitions happen gradually.",:hard,"Sustainable Lifestyle"),
      q("sl21","Which action reduces waste the MOST?",["Recycling everything","Avoiding unnecessary purchases","Washing in hot water","Buying duplicates"],1,"Avoiding waste at the source.",:hard,"Sustainable Lifestyle"),
      q("sl22","What is a \"waste footprint\"?",["Trash left on the ground","Total waste an individual or household produces","Footprint size","The amount a person recycles"],1,"Tracks how much waste you generate.",:hard,"Sustainable Lifestyle"),
      q("sl23","Which is a common mistake in sustainable living?",["Repairing items","Buying excess \"eco-friendly\" products","Reducing consumption","Using fewer resources"],1,"Buying too many \"eco\" items still leads to waste.",:hard,"Sustainable Lifestyle"),
      q("sl24","Why do lifestyle changes need to be maintained consistently?",["One-time actions don't create lasting impact","Sustainability is only about trends","Governments require it","It is expensive otherwise"],0,"Long-term behaviour creates long-term benefits.",:hard,"Sustainable Lifestyle")
    ]
  end
end
