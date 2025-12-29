$(document).ready(function() {
    
    // Initialize Slick Carousel for brand logos - disabled in favor of inline initialization
    // The inline script in HTML handles carousel initialization
    
    // Smooth scroll for anchor links
    $('a[href^="#"]').on('click', function(e) {
        e.preventDefault();
        var target = $(this.getAttribute('href'));
        if(target.length) {
            $('html, body').stop().animate({
                scrollTop: target.offset().top - 100
            }, 1000);
        }
    });

    // Sticky Header on Scroll
    let lastScroll = 0;
    $(window).scroll(function() {
        let currentScroll = $(this).scrollTop();
        const $header = $('.main-header');
        
        if (currentScroll > 50) {
            $header.addClass('scrolled');
        } else {
            $header.removeClass('scrolled');
        }
        
        lastScroll = currentScroll;
    });

    // Product card hover animations
    if ($('.product-card').length) {
        $('.product-card').hover(
            function() {
                $(this).find('.add-to-cart').animate({
                    backgroundColor: '#7c3aed'
                }, 200);
            },
            function() {
                $(this).find('.add-to-cart').animate({
                    backgroundColor: '#8b5cf6'
                }, 200);
            }
        );
    }

    // Add to cart button click animation
    if ($('.add-to-cart').length) {
        $('.add-to-cart').on('click', function(e) {
            e.preventDefault();
            var $button = $(this);
            var originalText = $button.text();
            
            $button.text('Added!').css('background', '#10b981');
            
            setTimeout(function() {
                $button.text(originalText).css('background', '#8b5cf6');
            }, 1500);
        });
    }

    // Logo rotation on click
    if ($('.logo').length) {
        $('.logo').on('click', function() {
            $(this).find('svg').css('transform', 'rotate(360deg)');
            setTimeout(function() {
                $('.logo svg').css('transform', 'rotate(0deg)');
            }, 600);
        });
    }

    // Parallax effect for mockup elements
    if ($('.search-bar').length || $('.recommendation-bubble').length || $('.product-cards').length || $('.price-bubble').length) {
        $(window).on('scroll', function() {
            var scrolled = $(window).scrollTop();
            
            if ($('.search-bar').length) $('.search-bar').css('transform', 'translateY(' + (scrolled * 0.1) + 'px)');
            if ($('.recommendation-bubble').length) $('.recommendation-bubble').css('transform', 'translateY(' + (scrolled * 0.15) + 'px)');
            if ($('.product-cards').length) $('.product-cards').css('transform', 'translateY(' + (scrolled * 0.08) + 'px)');
            if ($('.price-bubble').length) $('.price-bubble').css('transform', 'translateY(' + (scrolled * 0.12) + 'px)');
        });
    }

    // Typing effect for search bar
    if ($('.search-bar input').length) {
        const searchText = 'Search "find a matching wallet"...';
        let searchIndex = 0;
        
        function typeSearch() {
            if (searchIndex < searchText.length) {
                $('.search-bar input').attr('placeholder', searchText.substring(0, searchIndex + 1));
                searchIndex++;
                setTimeout(typeSearch, 100);
            }
        }
        
        setTimeout(typeSearch, 1000);
    }

    // Pulse animation for CTA buttons
    setInterval(function() {
        $('.primary-button, .cta-button').each(function() {
            $(this).animate({ 
                boxShadow: '0 8px 30px rgba(37, 99, 235, 0.5)' 
            }, 500).animate({ 
                boxShadow: '0 4px 16px rgba(37, 99, 235, 0.3)' 
            }, 500);
        });
    }, 3000);

    // Brand logo fade in on scroll
    // $(window).on('scroll', function() {
    //     var scrollTop = $(window).scrollTop();
    //     var windowHeight = $(window).height();
        
    //     $('.brand-logo').each(function(index) {
    //         var elementTop = $(this).offset().top;
            
    //         if (scrollTop + windowHeight > elementTop + 100) {
    //             $(this).delay(index * 100).animate({
    //                 opacity: 0.5
    //             }, 600);
    //         }
    //     });
    // });

    // Interactive rating stars
    if ($('.stars i').length) {
        $('.stars i').hover(
            function() {
                $(this).css({
                    'transform': 'scale(1.2)',
                    'transition': 'transform 0.2s ease'
                });
            },
            function() {
                $(this).css('transform', 'scale(1)');
            }
        );
    }

    // Nav link active state
    if ($('.nav-link').length) {
        // Main nav link click
        $('.main-nav .nav-link').on('click', function(e) {
            // Only handle if it's not a dropdown toggle or if clicking on non-dropdown item
            if (!$(this).hasClass('dropdown-toggle') || $(this).closest('.nav-item').hasClass('nav-item') && !$(this).closest('.nav-item').hasClass('dropdown')) {
                // Remove active class from all nav links
                $('.main-nav .nav-link').removeClass('active');
                // Add active class to clicked link
                $(this).addClass('active');
            }
        });
        
        // Handle dropdown item clicks - make parent dropdown active
        $('.dropdown-item').on('click', function(e) {
            // Remove active from all nav links
            $('.main-nav .nav-link').removeClass('active');
            // Add active to parent dropdown toggle only
            $(this).closest('.dropdown').find('.dropdown-toggle').addClass('active');
        });
        
        // Remove active class when clicking outside
        $(document).on('click', function(e) {
            if (!$(e.target).closest('.main-nav').length) {
                // Don't remove active class when clicking outside
            }
        });
    }

    // Smooth fade in for page load
    $('body').css('opacity', '0').animate({ opacity: 1 }, 800);

    // Mobile menu toggle (for future implementation)
    if ($('.mobile-menu-toggle').length) {
        $('.mobile-menu-toggle').on('click', function() {
            $('.main-nav').slideToggle(300);
        });
    }

    // Counter animation for rating
    if ($('.rating-text').length) {
        function animateCounter() {
            $('.rating-text').each(function() {
                var $this = $(this);
                var countTo = 4.8;
                
                $({ countNum: 0 }).animate({
                    countNum: countTo
                }, {
                    duration: 2000,
                    easing: 'linear',
                    step: function() {
                        $this.text(this.countNum.toFixed(1) + '/5');
                    },
                    complete: function() {
                        $this.text('4.8/5');
                    }
                });
            });
        }
        
        setTimeout(animateCounter, 1500);
    }

    // Initialize brand logos carousel
    if (typeof $.fn.slick !== 'undefined' && $('.brand-logos-carousel').length && !$('.brand-logos-carousel').hasClass('slick-initialized')) {
        try {
            $('.brand-logos-carousel').slick({
                slidesToShow: 6,
                slidesToScroll: 1,
                autoplay: true,
                autoplaySpeed: 0,
                speed: 5000,
                cssEase: 'linear',
                infinite: true,
                arrows: false,
                dots: false,
                pauseOnHover: false,
                pauseOnFocus: false,
                accessibility: false,
                focusOnSelect: false,
                focusOnChange: false,
                swipe: false,
                touchMove: false,
                draggable: false,
                variableWidth: false,
                waitForAnimate: false,
                responsive: [
                    {
                        breakpoint: 1024,
                        settings: {
                            slidesToShow: 4,
                            slidesToScroll: 1,
                            accessibility: false
                        }
                    },
                    {
                        breakpoint: 768,
                        settings: {
                            slidesToShow: 3,
                            slidesToScroll: 1,
                            accessibility: false
                        }
                    },
                    {
                        breakpoint: 480,
                        settings: {
                            slidesToShow: 2,
                            slidesToScroll: 1,
                            accessibility: false
                        }
                    }
                ]
            });
            console.log('Carousel initialized successfully - continuous scrolling enabled');
        } catch(e) {
            console.error('Carousel error:', e);
        }
    }


    // Counter Animation
    function animateCounter() {
        $('.counter').each(function() {
            const $this = $(this);
            const target = parseInt($this.attr('data-target'));
            const duration = 2000; // 2 seconds
            const increment = target / (duration / 16); // 60fps
            let current = 0;

            const timer = setInterval(function() {
                current += increment;
                if (current >= target) {
                    current = target;
                    clearInterval(timer);
                }
                $this.text(Math.floor(current));
            }, 16);
        });
    }

    // Check if element is in viewport
    function isInViewport(element) {
        if (element.length === 0) return false;
        
        const elementTop = element.offset().top;
        const elementBottom = elementTop + element.outerHeight();
        const viewportTop = $(window).scrollTop();
        const viewportBottom = viewportTop + $(window).height();
        
        // Element is in viewport when at least 30% is visible
        return elementBottom > viewportTop && elementTop < viewportBottom - 200;
    }

    // Trigger counter animation when section is in view
    function checkCounterAnimation() {
        const $section = $('.measurable-growth-section');
        
        if (isInViewport($section) && !$section.hasClass('counter-animated')) {
            $section.addClass('counter-animated');
            animateCounter();
        }
    }

    // Check on scroll
    $(window).on('scroll', checkCounterAnimation);
    
    // Check on page load
    $(document).ready(function() {
        checkCounterAnimation();
    });

    // Customer Stories Carousel
    $('.customer-stories-carousel').slick({
        infinite: true,
        slidesToShow: 1,
        slidesToScroll: 1,
        autoplay: true,
        dots: false,
        arrows: false,
        fade: true,
        speed: 600
    });

    // Custom navigation buttons
    $('.next-btn').click(function() {
        $('.customer-stories-carousel').slick('slickNext');
    });

    $('.prev-btn').click(function() {
        $('.customer-stories-carousel').slick('slickPrev');
    });

     // Testimonials Carousel (Horizontal)
    if ($('.testimonials-carousel').length > 0) {
        console.log('Initializing testimonials carousel...');
        console.log('Testimonial cards found:', $('.testimonials-carousel .testimonial-card').length);
        
        try {
            // Destroy existing instance if any
            if ($('.testimonials-carousel').hasClass('slick-initialized')) {
                $('.testimonials-carousel').slick('unslick');
            }
            
            $('.testimonials-carousel').slick({
                infinite: true,
                slidesToShow: 1,
                slidesToScroll: 1,
                autoplay: true,
                autoplaySpeed: 3000,
                dots: false,
                arrows: true,
                centerMode: true,
                centerPadding: '20%',
                focusOnSelect: true,
                speed: 800,
                pauseOnHover: false,
                pauseOnFocus: false,
                pauseOnDotsHover: false,
                cssEase: 'ease-in-out',
                draggable: true,
                swipe: true,
                touchMove: true,
                waitForAnimate: false,
                initialSlide: 1,
                responsive: [
                    {
                        breakpoint: 1200,
                        settings: {
                            slidesToShow: 1,
                            centerMode: true,
                            centerPadding: '20%'
                        }
                    },
                    {
                        breakpoint: 992,
                        settings: {
                            slidesToShow: 1,
                            centerMode: true,
                            centerPadding: '15%'
                        }
                    },
                    {
                        breakpoint: 768,
                        settings: {
                            slidesToShow: 1,
                            centerMode: true,
                            centerPadding: '50px',
                            arrows: false
                        }
                    },
                    {
                        breakpoint: 576,
                        settings: {
                            slidesToShow: 1,
                            centerMode: true,
                            centerPadding: '20px',
                            arrows: false
                        }
                    }
                ]
            });
            
            console.log('✅ Testimonials carousel initialized successfully!');
        } catch (error) {
            console.error('❌ Error initializing testimonials carousel:', error);
        }
    } else {
        console.log('⚠️ Testimonials carousel element not found');
    }
    
    // AI Solutions Section - Accordion Functionality
    $('.ai-feature-header').on('click', function() {
        const $item = $(this).closest('.ai-feature-item');
        const $body = $item.find('.ai-feature-body');
        const $toggle = $item.find('.ai-feature-toggle i');
        const featureType = $item.attr('data-feature');
        
        // If clicking on already active item, do nothing
        if ($item.hasClass('active')) {
            return;
        }
        
        // Close all other items
        $('.ai-feature-item').removeClass('active');
        $('.ai-feature-body').slideUp(300);
        $('.ai-feature-toggle i').removeClass('fa-chevron-up').addClass('fa-chevron-down');
        
        // Open clicked item
        $item.addClass('active');
        $body.slideDown(300);
        $toggle.removeClass('fa-chevron-down').addClass('fa-chevron-up');
        
        // Update section background color
        const $section = $('.ai-solutions-section');
        $section.attr('data-active-feature', featureType);
        
        // Update preview container
        const $previewContainer = $('.ai-preview-container');
        $previewContainer.attr('data-feature', featureType);
        
        // Hide all preview content
        $('.ai-preview-content').removeClass('active');
        
        // Show corresponding preview content with animation
        setTimeout(function() {
            $('.' + featureType + '-preview').addClass('active');
        }, 100);
    });

    // Plan Toggle Functionality (Monthly/Yearly)
    $('.plan-toggle-option').on('click', function() {
        const $option = $(this);
        const planType = $option.find('.plan-radio').val();
        
        // Update active state
        $('.plan-toggle-option').removeClass('active');
        $option.addClass('active');
        
        // Update radio button
        $('.plan-radio').prop('checked', false);
        $option.find('.plan-radio').prop('checked', true);
        
        // Get current currency
        const currentCurrency = $('.currency-btn.active').data('currency') || 'usd';
        
        // Update prices based on plan type
        $('.price-amount').each(function() {
            const $priceElement = $(this);
            let newPrice;
            
            // Determine which price to show based on plan type and currency
            if (planType === 'monthly') {
                newPrice = $priceElement.data('monthly-' + currentCurrency);
            } else {
                newPrice = $priceElement.data('yearly-' + currentCurrency);
            }
            
            // Only update if price data exists (skip free plan)
            if (newPrice !== undefined) {
                // Fade out
                $priceElement.fadeOut(200, function() {
                    // Update price
                    $priceElement.text(newPrice);
                    // Fade in
                    $priceElement.fadeIn(200);
                });
            }
        });
        
        console.log('Selected plan:', planType);
        
        // Optional: Add visual feedback
        $option.addClass('pulse-once');
        setTimeout(function() {
            $option.removeClass('pulse-once');
        }, 600);
    });

    // Currency Toggle Functionality
    $('.currency-btn').on('click', function() {
        const currency = $(this).data('currency');
        
        // Update active button
        $('.currency-btn').removeClass('active');
        $(this).addClass('active');
        
        // Update currency symbols
        let symbol = '$';
        if (currency === 'gbp') {
            symbol = '£';
        } else if (currency === 'eur') {
            symbol = '€';
        }
        
        // Update all currency symbols in pricing cards
        $('.currency-symbol').text(symbol);
        
        // Update all currency symbols in pricing matrix table
        $('.currency-sym').text(symbol);
        
        // Get current plan type (monthly or yearly)
        const planType = $('.plan-radio:checked').val() || 'yearly';
        
        // Update all prices in pricing cards with smooth animation
        $('.price-amount').each(function() {
            const $priceElement = $(this);
            let newPrice;
            
            // Get price based on plan type and currency
            if (planType === 'monthly') {
                newPrice = $priceElement.data('monthly-' + currency);
            } else {
                newPrice = $priceElement.data('yearly-' + currency);
            }
            
            // Fallback to old data attribute if new ones don't exist
            if (newPrice === undefined) {
                newPrice = $priceElement.data(currency);
            }
            
            // Only update if price exists
            if (newPrice !== undefined) {
                // Fade out
                $priceElement.fadeOut(200, function() {
                    // Update price
                    $priceElement.text(newPrice);
                    // Fade in
                    $priceElement.fadeIn(200);
                });
            }
        });
        
        // Update all prices in pricing matrix table with smooth animation
        $('.price-value').each(function() {
            const $priceElement = $(this);
            const newPrice = $priceElement.data(currency);
            
            if (newPrice !== undefined) {
                // Fade out
                $priceElement.fadeOut(200, function() {
                    // Update price with currency symbol
                    $priceElement.html('<span class="currency-sym">' + symbol + '</span>' + newPrice);
                    // Fade in
                    $priceElement.fadeIn(200);
                });
            }
        });
    });

    // Initialize Owl Carousel for Testimonials
    if ($('.testimonials-owl-carousel').length) {
        $('.testimonials-owl-carousel').owlCarousel({
            items: 1,
            loop: true,
            margin: 30,
            nav: true,
            dots: false,
            autoplay: true,
            autoplayTimeout: 5000,
            autoplayHoverPause: true,
            smartSpeed: 800,
            navText: ['<i class="fas fa-chevron-left"></i>', '<i class="fas fa-chevron-right"></i>'],
            responsive: {
                0: {
                    items: 1,
                    nav: false,
                    dots: false
                },
                768: {
                    items: 1,
                    nav: true,
                    dots: false
                },
                992: {
                    items: 1,
                    nav: true,
                    dots: false
                }
            }
        });
    }

});

