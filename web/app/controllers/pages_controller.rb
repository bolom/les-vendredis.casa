class PagesController < ApplicationController
  allow_unauthenticated_access

  def home
    @locale = params[:locale] == "fr" ? :fr : :en
    locale = @locale.to_s

    @home_journal_posts = JournalPost.published.where(locale: locale).recent_first.limit(3).to_a
    @home_faqs = home_faqs(locale)
    @home_gallery_sections = home_gallery_sections(locale)
  end

  private

  def home_faqs(locale)
    if locale == "fr"
      [
        {
          question: "Où se trouve exactement Les Vendredis ?",
          answer: "Dans les hauteurs de Sainte-Luce, au sud de la Martinique, entre forêt tropicale et plages."
        },
        {
          question: "Comment réserver ?",
          answer: "Vous pouvez passer par la demande directe sur le site, ou nous écrire pour caler une date."
        },
        {
          question: "Les animaux sont-ils acceptés ?",
          answer: "Oui, le lieu est pensé pour les séjours avec animaux, dans un cadre privé et calme."
        },
        {
          question: "Y a-t-il du Wi-Fi ?",
          answer: "Oui, mais le séjour reste volontairement simple et tourné vers l’extérieur."
        }
      ]
    else
      [
        {
          question: "Where exactly are Les Vendredis?",
          answer: "In the hills above Sainte-Luce, in the south of Martinique, between tropical forest and beaches."
        },
        {
          question: "How do I book?",
          answer: "Use the direct request form on the site, or write to us and we will check the dates."
        },
        {
          question: "Are pets welcome?",
          answer: "Yes. The place is designed for quiet stays with pets in a private setting."
        },
        {
          question: "Is there Wi-Fi?",
          answer: "Yes, but the stay is intentionally simple and oriented toward the outdoors."
        }
      ]
    end
  end

  def home_gallery_sections(locale)
    french = locale == "fr"

    [
      {
        number: "01",
        title_en: "The Domain",
        title_fr: "Le domaine",
        copy_en: "Before the A-frame, there is the land itself: the hills of Sainte-Luce, the palms, and the feeling of being alone in a piece of Martinique.",
        copy_fr: "Avant l'A-frame, il y a le terrain d'Anaïs : les hauteurs de Sainte-Luce, les palmiers, les collines et ce sentiment d'être seul quelque part en Martinique.",
        items: [
          {
            index: 0,
            src: "/public/images/jpk-cabane-vegetation-palmiers.webp",
            alt_en: "The A-frame seen through dense palms, Les Vendredis in Sainte-Luce",
            alt_fr: "L'A-frame vue à travers les palmiers, Les Vendredis à Sainte-Luce",
            caption_en: "The Domain",
            caption_fr: "Le domaine",
            css_class: "feature panorama"
          },
          {
            index: 1,
            src: "/public/images/jpk-detente-balancoire-collines.webp",
            alt_en: "A wooden swing in the garden with the Sainte-Luce hills behind",
            alt_fr: "Une balançoire en bois dans le jardin avec les collines de Sainte-Luce derrière",
            caption_en: "The hills hold the view.",
            caption_fr: "Les collines gardent la vue.",
            css_class: ""
          },
          {
            index: 2,
            src: "/public/images/jpk-cabane-cypers-angle.webp",
            alt_en: "The tip of the A-frame seen in low angle through a papyrus plant",
            alt_fr: "La pointe de l'A-frame en contre-plongée à travers un papyrus",
            caption_en: "Under the gable.",
            caption_fr: "Sous le pignon.",
            css_class: ""
          }
        ]
      },
      {
        number: "02",
        title_en: "The A-frame",
        title_fr: "L'A-frame",
        copy_en: "The A-frame is one part of the domain: open to the garden, tall under the gable, and always close to the outside.",
        copy_fr: "L'A-frame est une pièce du domaine : ouverte sur le jardin, haute sous le pignon et toujours proche du dehors.",
        items: [
          {
            index: 3,
            src: "/public/images/jpk-cabane-facade-plein-air.webp",
            alt_en: "The A-frame in Wapa shingles, palms and open sky",
            alt_fr: "L'A-frame en bardeaux de Wapa, palmiers et ciel ouvert",
            caption_en: "The A-frame",
            caption_fr: "L'A-frame",
            css_class: "feature"
          },
          {
            index: 4,
            src: "/public/images/jpk-cabane-interieur-vue-paysage.webp",
            alt_en: "Wood floor, cushions, ladder to the mezzanine, and the hills framed in the opening",
            alt_fr: "Plancher bois, coussins, échelle vers la mezzanine, et les mornes cadrés dans l'ouverture",
            caption_en: "Inside",
            caption_fr: "Le dedans",
            css_class: ""
          },
          {
            index: 5,
            src: "/public/images/jpk-cabane-vue-interieure-foret.webp",
            alt_en: "The A-frame nested in the forest, the inside visible through the foliage",
            alt_fr: "L'A-frame nichée dans la forêt, l'intérieur visible à travers le feuillage",
            caption_en: "Tucked in the green.",
            caption_fr: "Nichée dans le vert.",
            css_class: ""
          },
          {
            index: 6,
            src: "/public/images/jpk-detail-corde-noeud-cabane.webp",
            alt_en: "Braided rope knot with the A-frame tip in the background",
            alt_fr: "Nœud de corde tressée avec la pointe de l'A-frame en arrière-plan",
            caption_en: "Made by hand.",
            caption_fr: "Fait à la main.",
            css_class: ""
          }
        ]
      },
      {
        number: "03",
        title_en: "The Tropical Garden",
        title_fr: "Le jardin tropical",
        copy_en: "The garden is what we have most: mango, guava, bougainvillea, volcanic rocks, and a hillside that slowly closes around you.",
        copy_fr: "Le jardin est ce qu'on a de plus : manguiers, goyaviers, bougainvilliers, rochers volcaniques et une colline qui se referme doucement autour de vous.",
        items: [
          {
            index: 7,
            src: "/public/images/jpk-flore-passiflore-ouverte.webp",
            alt_en: "A fully open passion flower in the garden",
            alt_fr: "Une fleur de la passion pleinement ouverte dans le jardin",
            caption_en: "Passion flower.",
            caption_fr: "Fleur de la passion.",
            css_class: "feature"
          },
          {
            index: 8,
            src: "/public/images/jpk-flore-gingembre-rouge.webp",
            alt_en: "Red ginger flower close-up with the lush garden behind",
            alt_fr: "Fleur de gingembre rouge en gros plan avec le jardin verdoyant derrière",
            caption_en: "Red ginger.",
            caption_fr: "Gingembre rouge.",
            css_class: ""
          },
          {
            index: 9,
            src: "/public/images/jpk-flore-orchidee-coco-orange.webp",
            alt_en: "An orange orchid growing from a coconut shell attached to a tree trunk",
            alt_fr: "Une orchidée orange poussant depuis une coque de coco accrochée à un tronc",
            caption_en: "Orchid on coconut.",
            caption_fr: "Orchidée sur coco.",
            css_class: ""
          },
          {
            index: 10,
            src: "/public/images/jpk-flore-allamanda-jaune.webp",
            alt_en: "Yellow allamanda with a soft bokeh of orange flowers behind",
            alt_fr: "Allamanda jaune avec un bokeh doux de fleurs orange derrière",
            caption_en: "Yellow allamanda.",
            caption_fr: "Allamanda jaune.",
            css_class: ""
          },
          {
            index: 11,
            src: "/public/images/jpk-detail-panneau-vendredi.webp",
            alt_en: "Hand-engraved wooden sign in the foliage",
            alt_fr: "Panneau de bois gravé dans le feuillage",
            caption_en: "Vendredi.",
            caption_fr: "Vendredi.",
            css_class: ""
          }
        ]
      },
      {
        number: "04",
        title_en: "Outdoor Living",
        title_fr: "La vie dehors",
        copy_en: "Les Vendredis is lived outside: hammock time, breakfast with fruit, pets in the garden, an open kitchen, solar shower, and days that move slowly.",
        copy_fr: "Les Vendredis se vit dehors : hamac, petit déjeuner dans les fruits, animaux dans le jardin, cuisine ouverte, douche solaire et journées qui passent lentement.",
        items: [
          {
            index: 12,
            src: "/public/images/jpk-detente-hamac-bleu-gingembre.webp",
            alt_en: "Blue hammock in the tropical garden, red ginger flowers in the foreground",
            alt_fr: "Hamac bleu dans le jardin tropical, fleurs de gingembre rouge au premier plan",
            caption_en: "Hammock.",
            caption_fr: "Hamac.",
            css_class: "feature"
          },
          {
            index: 13,
            src: "/public/images/jpk-vie-fruits-tropicaux-dessus.webp",
            alt_en: "Top view of tropical fruit baskets and an awalé board at the centre",
            alt_fr: "Vue de dessus sur des corbeilles de fruits tropicaux et un jeu d'awalé au centre",
            caption_en: "Fruit from the garden.",
            caption_fr: "Les fruits du jardin.",
            css_class: ""
          },
          {
            index: 14,
            src: "/public/images/jpk-vie-bbq-feu.webp",
            alt_en: "Grilled meat and sausages on the barbecue with smoke rising",
            alt_fr: "Viandes grillées et saucisses sur le barbecue avec la fumée qui monte",
            caption_en: "The BBQ.",
            caption_fr: "Le BBQ.",
            css_class: ""
          },
          {
            index: 15,
            src: "/public/images/jpk-vie-samsam-portrait.webp",
            alt_en: "Samsam, the Creole dog, lying on the terrace",
            alt_fr: "Samsam, la chienne créole, couchée sur la terrasse",
            caption_en: "Samsam",
            caption_fr: "Samsam",
            css_class: ""
          }
        ]
      }
    ].each do |section|
      section[:title] = french ? section[:title_fr] : section[:title_en]
      section[:copy] = french ? section[:copy_fr] : section[:copy_en]
      section[:items].each do |item|
        item[:alt] = french ? item[:alt_fr] : item[:alt_en]
        item[:caption] = french ? item[:caption_fr] : item[:caption_en]
      end
    end
  end
end
